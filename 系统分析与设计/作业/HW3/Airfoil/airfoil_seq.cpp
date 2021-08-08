
// standard headers
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>
#include <omp.h>
#include <vector>
#include <unistd.h>
#include "writeVTK.h"

typedef double real;

// global constants
real gam, gm1, cfl, eps, mach, alpha, qinf[4];

typedef struct new_grid
{ /*grid struct*/
    int nnode, ncell, nedge, nbedge;
    double *x;
    int *cell;
    int *edge;
    int *bedge;
    int *becell;
    int *bound;
    int *ecell;
    int *cell2edge; // 2 means to
} grid;

/*
  cell   = (int *) malloc(4*ncell*sizeof(int));
  edge   = (int *) malloc(2*nedge*sizeof(int));
  ecell  = (int *) malloc(2*nedge*sizeof(int));
  bedge  = (int *) malloc(2*nbedge*sizeof(int));
  becell = (int *) malloc(  nbedge*sizeof(int));
  bound  = (int *) malloc(  nbedge*sizeof(int));
*/

double set_timer() // 设置计时器，获取当前时间
{
    return omp_get_wtime(); // Returns a value in seconds of the time elapsed from some point
}

double get_duration(double start) // 获取从start到此时的时间长度
{
    return omp_get_wtime() - start;
}

std::vector<std::vector<int>> edge_coloring(grid *Grid)
{
    int *edge2color = (int *)malloc(Grid->nedge * sizeof(int));
    for (int i = 0; i < Grid->nedge; ++i)
    {
        edge2color[i] = -1;
    }
    int max = 0;
    std::vector<std::vector<int>> color2edge; // 二维向量，外：颜色队列，内：某种颜色的边队列
    for (int edge_ind = 0; edge_ind < Grid->nedge; ++edge_ind) // 最外层循环：遍历每一条边
    {
        int color = 0;
        while (1) // 中间层循环：枚举颜色
        {
            bool valid_color = true;
            for (int i = 0; i < 4; ++i) // 最内层循环：比较外层循环指定一条边临接的两个四面体的四条边的颜色是否已经有color色的，有则换下一种颜色，没有则将这条边染成color色
            {
                if (edge2color[Grid->cell2edge[Grid->ecell[edge_ind] + i]] == color || edge2color[Grid->cell2edge[Grid->ecell[edge_ind + 1] + i]] == color)
                {
                    valid_color = false;
                }
            }
            // ecell每两个一组，记录第edge_ind条边所在的两个四面体的索引
            // cell2edge每四个一组，记录每个四面体的四条边的索引
            if (valid_color) // 上色，存入二维向量
            {
                edge2color[edge_ind] = color;
                if (color2edge.size() == color)
                {
                    color2edge.push_back(std::vector<int>(1, edge_ind));
                }
                else if (color < color2edge.size())
                {
                    color2edge[color].push_back(edge_ind);
                }
                else
                {
                    printf("ismet para van\n");
                }
                if (color > max)
                {
                    max = color;
                    // printf("total color num: %d\n", max);
                }
                break;
            }
            ++color;
        }
    }
    free(edge2color);
    return color2edge;
}

typedef struct
{
    grid *Grid;
    real *q;
    real *adt;
} CAT_ARG; //作为传入参数的结构

void *calculate_area_timstep(void *arg, int i)
{
    CAT_ARG *argu = (CAT_ARG *)arg;
    grid *Grid = argu->Grid;
    real *q = argu->q;
    real *adt = argu->adt;
    double dx, dy, ri, u, v, c;
    int *cell = Grid->cell;
    real *x = Grid->x;
    ri = 1.0f / q[4 * i + 0];
    u = ri * q[4 * i + 1];
    v = ri * q[4 * i + 2];
    c = sqrt(gam * gm1 * (ri * q[4 * i + 3] - 0.5f * (u * u + v * v)));

    dx = x[cell[4 * i + 1] * 2 + 0] - x[cell[4 * i + 0] * 2 + 0];
    dy = x[cell[4 * i + 1] * 2 + 1] - x[cell[4 * i + 0] * 2 + 1];
    adt[i] = fabs(u * dy - v * dx) + c * sqrt(dx * dx + dy * dy);

    dx = x[cell[4 * i + 2] * 2 + 0] - x[cell[4 * i + 1] * 2 + 0];
    dy = x[cell[4 * i + 2] * 2 + 1] - x[cell[4 * i + 1] * 2 + 1];
    adt[i] += fabs(u * dy - v * dx) + c * sqrt(dx * dx + dy * dy);

    dx = x[cell[4 * i + 3] * 2 + 0] - x[cell[4 * i + 2] * 2 + 0];
    dy = x[cell[4 * i + 3] * 2 + 1] - x[cell[4 * i + 2] * 2 + 1];
    adt[i] += fabs(u * dy - v * dx) + c * sqrt(dx * dx + dy * dy);

    dx = x[cell[4 * i + 0] * 2 + 0] - x[cell[4 * i + 3] * 2 + 0];
    dy = x[cell[4 * i + 0] * 2 + 1] - x[cell[4 * i + 3] * 2 + 1];
    adt[i] += fabs(u * dy - v * dx) + c * sqrt(dx * dx + dy * dy);
    adt[i] = adt[i] / cfl;
    //把四个点的xy值计算一下存起来

    return NULL;
}

void calculate_flux_residual(grid *Grid, int i, real *q, real *adt, real *res)
{
    double dx, dy, mu, ri, p1, vol1, p2, vol2, f;
    real *x = Grid->x;
    int *edge = Grid->edge;
    int *ecell = Grid->ecell;
    dx = x[edge[2 * i + 0] * 2 + 0] - x[edge[2 * i + 1] * 2 + 0];
    dy = x[edge[2 * i + 0] * 2 + 1] - x[edge[2 * i + 1] * 2 + 1];

    ri = 1.0f / q[ecell[2 * i + 0] * 4 + 0];
    p1 = gm1 * (q[ecell[2 * i + 0] * 4 + 3] - 0.5f * ri * (q[ecell[2 * i + 0] * 4 + 1] * q[ecell[2 * i + 0] * 4 + 1] + q[ecell[2 * i + 0] * 4 + 2] * q[ecell[2 * i + 0] * 4 + 2]));
    vol1 = ri * (q[ecell[2 * i + 0] * 4 + 1] * dy - q[ecell[2 * i + 0] * 4 + 2] * dx);

    ri = 1.0f / q[ecell[2 * i + 1] * 4 + 0];
    p2 = gm1 * (q[ecell[2 * i + 1] * 4 + 3] - 0.5f * ri * (q[ecell[2 * i + 1] * 4 + 1] * q[ecell[2 * i + 1] * 4 + 1] + q[ecell[2 * i + 1] * 4 + 2] * q[ecell[2 * i + 1] * 4 + 2]));
    vol2 = ri * (q[ecell[2 * i + 1] * 4 + 1] * dy - q[ecell[2 * i + 1] * 4 + 2] * dx);

    mu = 0.5f * (adt[ecell[2 * i + 0]] + adt[ecell[2 * i + 1]]) * eps;

    f = 0.5f * (vol1 * q[ecell[2 * i + 0] * 4 + 0] + vol2 * q[ecell[2 * i + 1] * 4 + 0]) + mu * (q[ecell[2 * i + 0] * 4 + 0] - q[ecell[2 * i + 1] * 4 + 0]);
    res[ecell[2 * i + 0] * 4 + 0] += f;
    res[ecell[2 * i + 1] * 4 + 0] -= f;

    f = 0.5f * (vol1 * q[ecell[2 * i + 0] * 4 + 1] + p1 * dy + vol2 * q[ecell[2 * i + 1] * 4 + 1] + p2 * dy) + mu * (q[ecell[2 * i + 0] * 4 + 1] - q[ecell[2 * i + 1] * 4 + 1]);
    res[ecell[2 * i + 0] * 4 + 1] += f;
    res[ecell[2 * i + 1] * 4 + 1] -= f;
    f = 0.5f * (vol1 * q[ecell[2 * i + 0] * 4 + 2] - p1 * dx + vol2 * q[ecell[2 * i + 1] * 4 + 2] - p2 * dx) + mu * (q[ecell[2 * i + 0] * 4 + 2] - q[ecell[2 * i + 1] * 4 + 2]);
    res[ecell[2 * i + 0] * 4 + 2] += f;
    res[ecell[2 * i + 1] * 4 + 2] -= f;
    f = 0.5f * (vol1 * (q[ecell[2 * i + 0] * 4 + 3] + p1) + vol2 * (q[ecell[2 * i + 1] * 4 + 3] + p2)) + mu * (q[ecell[2 * i + 0] * 4 + 3] - q[ecell[2 * i + 1] * 4 + 3]);
    res[ecell[2 * i + 0] * 4 + 3] += f;
    res[ecell[2 * i + 1] * 4 + 3] -= f;
}

void apply_boundary_conditions(grid *Grid, real *adt, real *q, real *res, real *qinf, int index)
{
    int i = index;
    double dx, dy, mu, ri, p1, vol1, p2, vol2, f;
    int nbedge = Grid->nbedge;
    int *bedge = Grid->bedge;
    int *becell = Grid->becell;
    int *bound = Grid->bound;
    real *x = Grid->x;
    dx = x[bedge[2 * i + 0] * 2 + 0] - x[bedge[2 * i + 1] * 2 + 0];
    dy = x[bedge[2 * i + 0] * 2 + 1] - x[bedge[2 * i + 1] * 2 + 1];

    ri = 1.0f / q[becell[i] * 4 + 0];
    p1 = gm1 * (q[becell[i] * 4 + 3] - 0.5f * ri * (q[becell[i] * 4 + 1] * q[becell[i] * 4 + 1] + q[becell[i] * 4 + 2] * q[becell[i] * 4 + 2]));

    if (bound[i] == 1)
    { //Far-field
        res[becell[i] * 4 + 1] += +p1 * dy;
        res[becell[i] * 4 + 2] += -p1 * dx;
    }
    else
    {
        vol1 = ri * (q[becell[i] * 4 + 1] * dy - q[becell[i] * 4 + 2] * dx);

        ri = 1.0f / qinf[0];
        p2 = gm1 * (qinf[3] - 0.5f * ri * (qinf[1] * qinf[1] + qinf[2] * qinf[2]));
        vol2 = ri * (qinf[1] * dy - qinf[2] * dx);

        mu = adt[becell[i]] * eps;

        f = 0.5f * (vol1 * q[becell[i] * 4 + 0] + vol2 * qinf[0]) + mu * (q[becell[i] * 4 + 0] - qinf[0]);
        res[becell[i] * 4 + 0] += f;
        f = 0.5f * (vol1 * q[becell[i] * 4 + 1] + p1 * dy + vol2 * qinf[1] + p2 * dy) + mu * (q[becell[i] * 4 + 1] - qinf[1]);
        res[becell[i] * 4 + 1] += f;
        f = 0.5f * (vol1 * q[becell[i] * 4 + 2] - p1 * dx + vol2 * qinf[2] - p2 * dx) + mu * (q[becell[i] * 4 + 2] - qinf[2]);
        res[becell[i] * 4 + 2] += f;
        f = 0.5f * (vol1 * (q[becell[i] * 4 + 3] + p1) + vol2 * (qinf[3] + p2)) + mu * (q[becell[i] * 4 + 3] - qinf[3]);
        res[becell[i] * 4 + 3] += f;
    }
}

void calculate_rms(grid *Grid, real *rms, real *adt, real *q, real *qold, real *res, int index)
{
    double del, adti;
    int i = index;
    adti = 1.0f / adt[i];
    for (int n = 0; n < 4; n++)
    {
        del = adti * res[4 * i + n];
        q[4 * i + n] = qold[4 * i + n] - del;
        res[4 * i + n] = 0.0f;
        *rms += del * del;
    }
}

void grid_free(grid *Grid)
{
    free(Grid->cell);
    free(Grid->edge);
    free(Grid->ecell);
    free(Grid->bedge);
    free(Grid->becell);
    free(Grid->bound);
    free(Grid->x);
    free(Grid->cell2edge);
}

void looping(int start, int end, void *(*func)(void *, int), void *arg)
{
#pragma omp for
    for (int i = start; i <= end; i++)
    {
        func(arg, i);
    }
}

grid *load_gird(const char *pathname)
{ /*pathname: the .dat file to load*/
    grid *new_grid = (grid *)malloc(sizeof(grid));
    FILE *fp;
    if ((fp = fopen(pathname, "r")) == NULL)
    { /*opne grid file*/
        printf("can't open file new_grid.dat\n");
        exit(-1);
    }
    if (fscanf(fp, "%d %d %d %d \n", &new_grid->nnode, &new_grid->ncell, &new_grid->nedge, &new_grid->nbedge) != 4)
    {
        printf("error reading from new_grid.dat\n");
        exit(-1);
    }
    new_grid->cell = (int *)malloc(4 * new_grid->ncell * sizeof(int));
    new_grid->edge = (int *)malloc(2 * new_grid->nedge * sizeof(int));
    new_grid->ecell = (int *)malloc(2 * new_grid->nedge * sizeof(int));
    new_grid->bedge = (int *)malloc(2 * new_grid->nbedge * sizeof(int));
    new_grid->becell = (int *)malloc(new_grid->nbedge * sizeof(int));
    new_grid->bound = (int *)malloc(new_grid->nbedge * sizeof(int));
    new_grid->x = (real *)malloc(2 * new_grid->nnode * sizeof(real));
    new_grid->cell2edge = (int *)malloc(4 * new_grid->ncell * sizeof(int));
    
    for (int i = 0; i < 4 * new_grid->ncell; ++i)
    {
        new_grid->cell2edge[i] = -1;
    }
    for (int i = 0; i < new_grid->nnode; i++)
    {
        if (fscanf(fp, "%lf %lf \n", &new_grid->x[2 * i], &new_grid->x[2 * i + 1]) != 2)
        {
            printf("error reading from new_grid.dat\n");
            exit(-1);
        }
    }
    for (int i = 0; i < new_grid->ncell; i++)
    {
        if (fscanf(fp, "%d %d %d %d \n", &new_grid->cell[4 * i], &new_grid->cell[4 * i + 1], &new_grid->cell[4 * i + 2], &new_grid->cell[4 * i + 3]) != 4)
        {
            printf("error reading from new_grid.dat\n");
            exit(-1);
        }
    }

    for (int n = 0; n < new_grid->nedge; n++)
    {
        if (fscanf(fp, "%d %d %d %d \n", &new_grid->edge[2 * n], &new_grid->edge[2 * n + 1], &new_grid->ecell[2 * n], &new_grid->ecell[2 * n + 1]) != 4)
        {
            printf("error reading from new_grid.dat\n");
            exit(-1);
        }
        for (int i = 0; i < 4; ++i)
        {
            if (new_grid->cell2edge[new_grid->ecell[2 * n] + i] == -1)
            {
                new_grid->cell2edge[new_grid->ecell[2 * n] + i] = n;
                break;
            }
        }
        for (int i = 0; i < 4; ++i)
        {
            if (new_grid->cell2edge[new_grid->ecell[2 * n + 1] + i] == -1)
            {
                new_grid->cell2edge[new_grid->ecell[2 * n + 1] + i] = n;
                break;
            }
        }
    } /*bedge[0],bedge[1]:edge bedge[2]:becell bedge[3]:bound*/

    for (int n = 0; n < new_grid->nbedge; n++)
    {
        if (fscanf(fp, "%d %d %d %d \n", &new_grid->bedge[2 * n], &new_grid->bedge[2 * n + 1], &new_grid->becell[n], &new_grid->bound[n]) != 4)
        {
            printf("error reading from new_grid.dat\n");
            exit(-1);
        }
    }
    fclose(fp);
    return new_grid;
}

void user()
{
    real *q, *qold, *adt, *res;

    int niter;
    real rms;

    //timer
    double wall_t1, wall_t2;

    // read in grid

    printf("reading in grid \n");

    grid *Grid = load_gird("./new_grid.dat"); //load in grid
    q = (real *)malloc(4 * (Grid->ncell) * sizeof(real));
    qold = (real *)malloc(4 * (Grid->ncell) * sizeof(real));
    res = (real *)malloc(4 * (Grid->ncell) * sizeof(real));
    adt = (real *)malloc((Grid->ncell) * sizeof(real));

    //set variables for graph coloring
    std::vector<std::vector<int>> color2edge = edge_coloring(Grid);
    printf("%ld %ld %ld %ld %ld %ld", color2edge[0].size(), color2edge[1].size(), color2edge[2].size(), color2edge[3].size(), color2edge[4].size(), color2edge[5].size());
    
    // set constants and initialise flow field and residual (流场和残余应力)

    printf("initialising flow field \n");

    gam = 1.4f;
    gm1 = gam - 1.0f;
    cfl = 0.9f;
    eps = 0.05f;

    real mach = 0.4f;
    real alpha = 3.0f * atan(1.0f) / 45.0f;
    real p = 1.0f;
    real r = 1.0f;
    real u = sqrt(gam * p / r) * mach;
    real e = p / (r * gm1) + 0.5f * u * u;

    qinf[0] = r;
    qinf[1] = r * u;
    qinf[2] = 0.0f;
    qinf[3] = r * e;

    for (int n = 0; n < Grid->ncell; n++)
    {
        for (int m = 0; m < 4; m++)
        {
            q[4 * n + m] = qinf[m];
            res[4 * n + m] = 0.0f;
        }
    }

    //initialise timers for total execution wall time
    wall_t1 = set_timer();

    // main time-marching loop

    niter = 1000;
    double save = 0, area = 0, update = 0, flux_res = 0, perem = 0, wall_t_a = 0, wall_t_b = 0;

    CAT_ARG cat_arg;
    cat_arg.Grid = Grid;
    cat_arg.q = q;
    cat_arg.adt = adt;

    #pragma omp parallel
    {
        for (int iter = 1; iter <= niter; iter++)
        {
            wall_t_b = set_timer();
            // save old flow solution
            #pragma omp for
            for (int i = 0; i < Grid->ncell; i++)
            {
                for (int n = 0; n < 4; n++)
                    qold[4 * i + n] = q[4 * i + n];
            }

            save += get_duration(wall_t_b);

            // predictor/corrector(预估/校正) update loop
            for (int k = 0; k < 2; k++)
            {
                #pragma omp single
                {
                    wall_t_b = set_timer();
                }

                looping(0, Grid->ncell - 1, calculate_area_timstep, (void *)&cat_arg);

                #pragma omp single
                {
                    area += get_duration(wall_t_b);
                    // calculate flux residual
                    wall_t_b = set_timer();
                }

                for (size_t color = 0; color < color2edge.size(); ++color)
                {
                    #pragma omp for
                    for (size_t ind = 0; ind < color2edge[color].size(); ++ind)
                    {
                        calculate_flux_residual(Grid, color2edge[color][ind], q, adt, res);
                    }
                }

                #pragma omp single
                {
                    flux_res += get_duration(wall_t_b);
                    // apply boundary conditions
                    wall_t_b = set_timer();
                    for (int i = 0; i < Grid->nbedge; i++)
                    {
                        apply_boundary_conditions(Grid, adt, q, res, qinf, i);
                    }
                    perem += get_duration(wall_t_b);

                    // update flow field
                    wall_t_b = set_timer();
                    rms = 0.0;
                }

                #pragma omp for reduction(+ : rms) 
                for (int i = 0; i < Grid->ncell; i++)
                {
                    calculate_rms(Grid, &rms, adt, q, qold, res, i);
                }
                update += get_duration(wall_t_b);
            }

            #pragma omp single
            {
                rms = sqrt(rms / (double)Grid->ncell);
                if (iter % 100 == 0)
                {
                    printf(" %d  %10.5e \n", iter, rms);
                    printf("\tsave: %f\n", save);
                    printf("\tarea: %f\n", area);
                    printf("\tflux_res: %f\n", flux_res);
                    printf("\tperem: %f\n", perem);
                    printf("\tupdate: %f\n", update);
                    char buf[50];
                    sprintf(buf, "out%d.vtk", iter);
                    WriteMeshToVTKAscii(buf, Grid->x, Grid->nnode, Grid->cell, Grid->ncell, q);
                }
            }
        }
    }
    wall_t2 = get_duration(wall_t1);

    printf("Max total runtime = \n%f\n", wall_t2);
    free(q);
    free(qold);
    free(res);
    free(adt);
    grid_free(Grid);
}

int main(int argc, char **argv)
{
    user();
}

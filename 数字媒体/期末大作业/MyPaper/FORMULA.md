
$$
令两个点列为P_1,P_2 \\
C_1 = \sum P_1 / n, C_2 = \sum P_2 \\
S_1 = \sqrt{\frac{\sum(P_1 - C_1)^2}{n}},
S_2 = \sqrt{\frac{\sum(P_2 - C_2)^2}{n}} \\
P_1' = \frac{P_1 - C_1}{S_1},
P_2' = \frac{P_2 - C_2}{S_2} \\
A = P_1'^T \cdot P_2' \\
A = U \Sigma V^T (奇异值分解) \\
R^T = U \cdot V \\
A_1 = \frac{S_2}{S_1}R \\
A_2 = C_2^T - A_1 \cdot C_1^T \\
M = [[A_1,A_2]^T, [0,0,1]^T]^T
$$

$$
令点列为P，像素点(x,y)的像素值为Img(x,y) \\
X = \lfloor P_x \rfloor, Y = \lfloor P_y \rfloor \\
dX = P_x - X, dY = P_y - Y \\
P_{top} = (1-dX)Img(Y,X)^T + (dX)Img(Y,X+1) \\
P_{bottom} = (1-dX)Img(Y+1,X)^T + (dX)Img(Y+1,X+1) \\
P_{interpolation}^T = (1-dY)P_{top} + (dY)P_{bottom}
$$




$$
Img_{result} = Img_{dst} \cdot \frac{Blur_{src}}{Blur_{dst}}
$$

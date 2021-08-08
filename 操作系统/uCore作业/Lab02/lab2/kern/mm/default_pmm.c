#include <pmm.h>
#include <list.h>
#include <string.h>
#include <default_pmm.h>

/*  In the First Fit algorithm, the allocator keeps a list of free blocks
 * (known as the free list). Once receiving a allocation request for memory,
 * it scans along the list for the first block that is large enough to satisfy
 * the request. If the chosen block is significantly larger than requested, it
 * is usually splitted, and the remainder will be added into the list as
 * another free block.
 *  Please refer to Page 196~198, Section 8.2 of Yan Wei Min's Chinese book
 * "Data Structure -- C programming language".
*/

// 在First Fit算法中，分配器保持一个空闲块列表(称为空闲列表)。一旦收到内存分配请求，它会沿着列表扫描第一个足够大的块来满足请求。如果选择的块明显大于请求的块，则通常将其分割，其余的块将作为另一个空闲块添加到列表中。

// LAB2 EXERCISE 1: YOUR CODE
// you should rewrite functions: `default_init`, `default_init_memmap`,
// `default_alloc_pages`, `default_free_pages`.

/*
 * Details of FFMA
 * (1) Preparation:
 *  In order to implement the First-Fit Memory Allocation (FFMA), we should
 * manage the free memory blocks using a list. The struct `free_area_t` is used
 * for the management of free memory blocks.
 *  First, you should get familiar with the struct `list` in list.h. Struct
 * `list` is a simple doubly linked list implementation. You should know how to
 * USE `list_init`, `list_add`(`list_add_after`), `list_add_before`, `list_del`,
 * `list_next`, `list_prev`.
 *  There's a tricky method that is to transform a general `list` struct to a
 * special struct (such as struct `page`), using the following MACROs: `le2page`
 * (in memlayout.h), (and in future labs: `le2vma` (in vmm.h), `le2proc` (in
 * proc.h), etc).
 * (2) `default_init`:
 *  You can reuse the demo `default_init` function to initialize the `free_list`
 * and set `nr_free` to 0. `free_list` is used to record the free memory blocks.
 * `nr_free` is the total number of the free memory blocks.
 * (3) `default_init_memmap`:
 *  CALL GRAPH: `kern_init` --> `pmm_init` --> `page_init` --> `init_memmap` -->
 * `pmm_manager` --> `init_memmap`.
 *  This function is used to initialize a free block (with parameter `addr_base`,
 * `page_number`). In order to initialize a free block, firstly, you should
 * initialize each page (defined in memlayout.h) in this free block. This
 * procedure includes:
 *  - Setting the bit `PG_property` of `p->flags`, which means this page is
 * valid. P.S. In function `pmm_init` (in pmm.c), the bit `PG_reserved` of
 * `p->flags` is already set.
 *  - If this page is free and is not the first page of a free block,
 * `p->property` should be set to 0.
 *  - If this page is free and is the first page of a free block, `p->property`
 * should be set to be the total number of pages in the block.
 *  - `p->ref` should be 0, because now `p` is free and has no reference.
 *  After that, We can use `p->page_link` to link this page into `free_list`.
 * (e.g.: `list_add_before(&free_list, &(p->page_link));` )
 *  Finally, we should update the sum of the free memory blocks: `nr_free += n`.
 * (4) `default_alloc_pages`:
 *  Search for the first free block (block size >= n) in the free list and reszie
 * the block found, returning the address of this block as the address required by
 * `malloc`.
 *  (4.1)
 *      So you should search the free list like this:
 *          list_entry_t le = &free_list;
 *          while((le=list_next(le)) != &free_list) {
 *          ...
 *      (4.1.1)
 *          In the while loop, get the struct `page` and check if `p->property`
 *      (recording the num of free pages in this block) >= n.
 *              struct Page *p = le2page(le, page_link);
 *              if(p->property >= n){ ...
 *      (4.1.2)
 *          If we find this `p`, it means we've found a free block with its size
 *      >= n, whose first `n` pages can be malloced. Some flag bits of this page
 *      should be set as the following: `PG_reserved = 1`, `PG_property = 0`.
 *      Then, unlink the pages from `free_list`.
 *          (4.1.2.1)
 *              If `p->proerty > n`, we should re-calculate number of the rest
 *          pages of this free block. (e.g.: `le2page(le,page_link))->property
 *          = p->property - n;`)
 *          (4.1.3)
 *              Re-caluclate `nr_free` (number of the the rest of all free block).
 *          (4.1.4)
 *              return `p`.
 *      (4.2)
 *          If we can not find a free block with its size >=n, then return NULL.
 * (5) `default_free_pages`:
 *  re-link the pages into the free list, and may merge small free blocks into
 * the big ones.
 *  (5.1)
 *      According to the base address of the withdrawed blocks, search the free
 *  list for its correct position (with address from low to high), and insert
 *  the pages. (May use `list_next`, `le2page`, `list_add_before`)
 *  (5.2)
 *      Reset the fields of the pages, such as `p->ref` and `p->flags` (PageProperty)
 *  (5.3)
 *      Try to merge blocks at lower or higher addresses. Notice: This should
 *  change some pages' `p->property` correctly.
 */
free_area_t free_area;

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

// LAB2 EXERCISE 1: 19335286

// REWRITE default_init
static void default_init(void){
	list_init(&free_list);
	nr_free = 0;
}

// REWRITE default_init_memmap
static void default_init_memmap(struct Page *base, size_t n){
	assert(n > 0);
	
	// 初始化空闲块首部的页base
	assert(PageReserved(base)); // 检查base标志位
	base->flags = 0;
	base->property = n; // 设置base指向的页为空闲块首部
	set_page_ref(base, 0); // 置为ref为0
    SetPageProperty(base); // 设置base指向的页为空闲块首部
    
    // 便历、初始化非空闲块首部的页
    struct Page *t = NULL; 
    for (t = base + 1; t < base + n; t ++) {
        assert(PageReserved(t)); // 由于函数pmm_init已赋值保留位为0,这里仅需测试保留位是否被正确置0。
        t->flags = t->property = 0; // 设置该页不是空闲块首部
        set_page_ref(t, 0); // 置为ref为0
    }
    
    // 更新链表
    nr_free += n; // 更新空闲页的总数
    list_add(&free_list, &(base->page_link)); // 将该空闲块插入页表（空闲块）链表中。
}

// REWRITE default_alloc_pages
static struct Page* default_alloc_pages(size_t n){
	assert(n > 0);
	if(n > nr_free){ 
		return NULL; // 如果请求页数比当前空闲总页数还大，拒绝请求	，但没必要结束程序
	}
	
	struct Page *p = NULL, *p2 = NULL;
	
	list_entry_t *l = list_next(&free_list);
    while (l != &free_list){ // 从头遍历链表
		 p = le2page(l, page_link);
		 l = list_next(l); 
		 if(p->property >= n){ // 找到第一个页数>=n的空闲块
		 	p2 = p; // p2即满足条件的空闲块首部页
		 	break;
		 }
	}
	
	if(p2 != NULL){
		if(p2->property == n){ // p2空闲块大小刚好等于所需页数
			nr_free -= n;
			ClearPageProperty(p2);
			list_del(&(p2->page_link)); // 将p2从链表中删除
		}
		else if(p2->property > n){ // p2空闲块大小大于所需页数
			p = p2 + n; // 剩下的页组合在一起变成p，修改p的属性，重新加入链表
			p->property = p2->property - n;
			SetPageProperty(p);
			nr_free -= n;
			ClearPageProperty(p2);
			list_add_after(&(p2->page_link), &(p->page_link));
			list_del(&(p2->page_link)); // 将p2从链表中删除
			//list_add(&free_list, &(p->page_link)); // 将p加入链表
		}
	}
	return p2;
}

// REWRITE default_free_pages
static void default_free_pages(struct Page *base, size_t n){ // base~base+n 是归还给空闲链表的页
	assert(n > 0);
	// 清空内容
	for(struct Page *i = base; i < base + n; i++){
		assert(!PageReserved(i)); 
		assert(!PageProperty(i));
		i->flags = 0;
		set_page_ref(i, 0);
	}
	
	// 四种情况：两个块合并（前后和后前）、三个块合并、单独成块
	struct Page *p = NULL;
	
	nr_free += n;
	SetPageProperty(base);
	base->property = n;

    list_entry_t *l = list_next(&free_list);
    while (l != &free_list) { // 遍历，合并
        p = le2page(l, page_link); 
        l = list_next(l);       
        if (base + base->property == p) { // base 合并 p
        	ClearPageProperty(p);
            base->property += p->property;
            list_del(&(p->page_link)); // 断开被合并的块在free_list的链接
        }
        else if (p + p->property == base) { // p 合并 base
        	ClearPageProperty(base);
            p->property += base->property;
            list_del(&(p->page_link)); // 断开被合并的块在free_list的链接
            base = p; // 更新 base 为 p
        }
    }
    
    l = list_next(&free_list);
    while (l != &free_list){ //遍历，找位置按序插入
        p = le2page(l, page_link);
        if (base + base->property < p){
            break;
        }
        l = list_next(l);   
    }
    list_add_before(l, &(base->page_link)); // 若free_list为空可直接插入base
}



/*
static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
}

static void
default_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
        assert(PageReserved(p)); 
        p->flags = p->property = 0; 
        set_page_ref(p, 0); 
    }
    base->property = n;
    SetPageProperty(base);
    nr_free += n;
    list_add(&free_list, &(base->page_link));
}

static struct Page *
default_alloc_pages(size_t n) {
    assert(n > 0);
    if (n > nr_free) {
        return NULL;
    }
    struct Page *page = NULL;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
        struct Page *p = le2page(le, page_link);
        if (p->property >= n) {
            page = p;
            break;
        }
    }
    if (page != NULL) {
        list_del(&(page->page_link));
        if (page->property > n) {
            struct Page *p = page + n;
            p->property = page->property - n;
            list_add(&free_list, &(p->page_link));
    	}
        nr_free -= n;
        ClearPageProperty(page);
    }
    return page;
}

static void
default_free_pages(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
        assert(!PageReserved(p) && !PageProperty(p));
        p->flags = 0;
        set_page_ref(p, 0);
    }
    base->property = n;
    SetPageProperty(base);
    list_entry_t *le = list_next(&free_list);
    while (le != &free_list) { 
        p = le2page(le, page_link);
        le = list_next(le);
        if (base + base->property == p) {
            base->property += p->property;
            ClearPageProperty(p);
            list_del(&(p->page_link));
        }
        else if (p + p->property == base) {
            p->property += base->property; 
            ClearPageProperty(base);
            base = p;
            list_del(&(p->page_link));
        }
    }
    nr_free += n;
    list_add(&free_list, &(base->page_link)); //不对，插入过程要保证有序，不能直接插入链表头
}
*/

static size_t
default_nr_free_pages(void) {
    return nr_free;
}

static void
basic_check(void) {
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
    assert((p0 = alloc_page()) != NULL);
    assert((p1 = alloc_page()) != NULL);
    assert((p2 = alloc_page()) != NULL);

    assert(p0 != p1 && p0 != p2 && p1 != p2);
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);

    assert(page2pa(p0) < npage * PGSIZE);
    assert(page2pa(p1) < npage * PGSIZE);
    assert(page2pa(p2) < npage * PGSIZE);

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    assert(alloc_page() == NULL);

    free_page(p0);
    free_page(p1);
    free_page(p2);
    assert(nr_free == 3);

    assert((p0 = alloc_page()) != NULL);
    assert((p1 = alloc_page()) != NULL);
    assert((p2 = alloc_page()) != NULL);

    assert(alloc_page() == NULL);

    free_page(p0);
    assert(!list_empty(&free_list));

    struct Page *p;
    assert((p = alloc_page()) == p0);
    assert(alloc_page() == NULL);

    assert(nr_free == 0);
    free_list = free_list_store;
    nr_free = nr_free_store;

    free_page(p);
    free_page(p1);
    free_page(p2);
}

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
        count ++, total += p->property;
    }
    assert(total == nr_free_pages());

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
    assert(p0 != NULL);
    assert(!PageProperty(p0));

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
    assert(alloc_pages(4) == NULL);
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
    assert((p1 = alloc_pages(3)) != NULL);
    assert(alloc_page() == NULL);
    assert(p0 + 2 == p1);

    p2 = p0 + 1;
    free_page(p0);
    free_pages(p1, 3);
    assert(PageProperty(p0) && p0->property == 1);
    assert(PageProperty(p1) && p1->property == 3);
	
    assert((p0 = alloc_page()) == p2 - 1);
    free_page(p0);
    assert((p0 = alloc_pages(2)) == p2 + 1);

    free_pages(p0, 2);
    free_page(p2);

    assert((p0 = alloc_pages(5)) != NULL);
    assert(alloc_page() == NULL);

    assert(nr_free == 0);
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
    }
    assert(count == 0);
    assert(total == 0);
}

const struct pmm_manager default_pmm_manager = {
    .name = "default_pmm_manager",
    .init = default_init,
    .init_memmap = default_init_memmap,
    .alloc_pages = default_alloc_pages,
    .free_pages = default_free_pages,
    .nr_free_pages = default_nr_free_pages,
    .check = default_check,
};


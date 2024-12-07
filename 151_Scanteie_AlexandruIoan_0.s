.data
    format_scanf: .asciz "%d \n"         
    format_printf: .asciz "%d "
    format_memory_get: .asciz "(%d, %d)\n" 
    format_memory_add: .asciz "%d: (%d, %d)\n"   
    format_newline: .asciz "\n"  
    n: .long 20
    v: .space 4096 # 4 * 1024
    auxVar: .long 0

# movl  %ecx, (%edi,%ecx,4)  v[i] = i , %ecx = i
# movl  $2, (%edi,%ecx,4) v[i] =2 

.text
print_vector: # void print_vector()
    pushl %ebp
    movl %esp, %ebp

    # for(int i=0;i<n;i++)
    # { printf("%d\n", v[i]); }

    movl $0, %ecx                     # i = 0
    lea v, %edi # %edi = *(v[0])

    print_vector_loop:
        cmp n, %ecx  # ecx >= n
        jge print_vector_exit

        pushl %ecx # %ecx caller saved

        pushl (%edi,%ecx,4) # v[i]
        pushl $format_printf
        call printf
        popl %edx
        popl %edx

        popl %ecx

        incl %ecx
        jmp print_vector_loop 


    print_vector_exit:
        pushl $format_newline
        call printf
        popl %edx

        popl %ebp
        ret

print_vectorRange: # void print_vectorRange(a,b)
    pushl %ebp
    movl %esp, %ebp

    # movl 8(%ebp), %eax # a
    # movl 12(%ebp), %ebx # b

    movl 8(%ebp), %ecx    # i = a
    lea v, %edi  # %edi = *(v[0])

    print_vectorRange_loop:
        cmp 12(%ebp), %ecx  # ecx >= b
        jge print_vectorRange_exit

        pushl %ecx # %ecx caller saved

        pushl (%edi,%ecx,4) # v[i]
        pushl $format_printf
        call printf
        popl %edx
        popl %edx

        popl %ecx

        incl %ecx
        jmp print_vectorRange_loop 


    print_vectorRange_exit:
        pushl $format_newline
        call printf
        popl %edx

        popl %ebp
        ret

memory_add: # void memory_add(int fd, int size)
    pushl %ebp
    movl %esp, %ebp

    pushl $0 # start -4(%ebp)
    pushl $0 # lenght -8(%ebp)
    pushl $0 # ok -12(%ebp)
    pushl $0 # blocuri -16(%ebp)

    movl $0, %ecx  # i = 0
    lea v, %edi # %edi = *(v[0])

    movl 12(%ebp), %eax # file size
    pushl %eax # file size 

    xorl %edx, %edx
    movl $8, %ebx
    div %ebx 
    

    cmpl $0, %edx
    je set_blocuri
    incl %eax

    set_blocuri: # eax = nr blocuri = [size(kb)/8(kb)]
        movl %eax, -16(%ebp)


    memory_add_loop:
        # for(int i = 0; i < n; i++){
        #     if(v[i] == 0){
        #         start = i;
        #         length = 0;
        #     }
        #     while(v[i] == 0){
        #         length++;
        #         if(length == blocuri){
        #             adaugi fisierul
        #         }
        #     }
        # }

        cmp n, %ecx  # ecx >= n
        jge memory_add_not_find

        cmp $0,(%edi,%ecx,4) 
        jne memory_add_continue

        movl %ecx, -4(%ebp) # start = i;
        movl $0, -8(%ebp) # lenght = 0;
        movl $1, -12(%ebp) # ok = 1;

        memory_add_while:
            cmp n, %ecx  # ecx >= n
            jge memory_add_not_find

            cmpl $0, (%edi, %ecx, 4)
            jne memory_add_continue
            
            incl -8(%ebp) # lenght ++
            incl %ecx

            movl -8(%ebp), %edx
            cmpl %edx,-16(%ebp) #  if(length == blocuri)
            je find_space_for_file
            jmp memory_add_while

    memory_add_continue:    
        incl %ecx
        jmp memory_add_loop

    find_space_for_file: # set (start,start+blocuri) = fd
        movl -4(%ebp), %ecx
        movl -16(%ebp), %ebx
        addl %ecx, %ebx # ebx = start + blocuri
        
        find_space_for_file_loop:
            cmp %ebx, %ecx
            jge memory_add_print

            movl 8(%ebp), %edx
            movl %edx, (%edi,%ecx,4) # v[i] = fd;

            incl %ecx
            jmp find_space_for_file_loop 
        decl %ebx

    memory_add_not_find:
        movl $0, -4(%ebp)
        movl $0, %ebx

    memory_add_print:
        pushl %ebx
        pushl -4(%ebp)
        pushl 8(%ebp)
        pushl $format_memory_add
        call printf
        popl %edx
        popl %edx
        popl %edx
        popl %edx

    memory_add_exit:
        popl %edx
        popl %edx
        popl %edx
        popl %edx

        popl %edx # for eax

        popl %ebp
        ret
memory_get: # void memory_get(int fd)
    pushl %ebp
    movl %esp, %ebp
    pushl $0 # start -4(%ebp)
    pushl $0 # end -8(%ebp)
    pushl $0 # ok -12(%ebp)

    movl $0, %ecx  # i = 0
    lea v, %edi # %edi = *(v[0])

    movl 8(%ebp), %eax # file descriptor

    memory_get_loop:
        cmp n, %ecx  # ecx >= n
        jge memory_get_exit

        cmp %eax, (%edi,%ecx,4) # if (fd == v[i])
        jne memory_get_continue

        cmp $0,-12(%ebp) # if (ok == 0)
        je set_start
        jmp set_end

        set_start:
            movl %ecx, -4(%ebp) # start = i
            movl $1,-12(%ebp) 
        set_end:
            movl %ecx, -8(%ebp) # end = i

        memory_get_continue:
            incl %ecx
            jmp memory_get_loop 

    memory_get_exit:
        pushl -8(%ebp)
        pushl -4(%ebp)
        pushl $format_memory_get
        call printf
        popl %edx
        popl %edx
        popl %edx

        popl %edx
        popl %edx
        popl %edx

        popl %ebp
        ret

memory_delete: # void memory_delete(int fd)
    pushl %ebp
    movl %esp, %ebp

    movl $0, %ecx  # i = 0
    lea v, %edi # %edi = *(v[0])

    movl 8(%ebp), %eax # file descriptor

    memory_delete_loop:
        cmp n, %ecx  # ecx >= n
        jge memory_delete_exit

        cmp %eax, (%edi,%ecx,4) # if (fd == v[i])
        jne memory_delete_continue

        xorl %edx, %edx
        movl %edx, (%edi,%ecx,4)

        memory_delete_continue:
            incl %ecx
            jmp memory_delete_loop 

    memory_delete_exit:
        popl %ebp
        ret

memory_defragmentation: # void memory_defragmentation()
    

    


scanf_vector:
    pushl %ebp
    movl %esp, %ebp

    # for(int i=0;i<n;i++)
    # { scanf("%d ", v[i]); }

    movl $0, %ecx                     # i = 0
    lea v, %edi # %edi = *(v[0])

    scanf_vector_loop:
        cmp n, %ecx  # ecx >= n
        jge scanf_vector_exit

        pushl %ecx # %ecx caller saved

        pushl $auxVar # v[i]
        pushl $format_scanf
        call scanf
        popl %edx
        popl %edx

        popl %ecx

        movl auxVar, %eax
        movl %eax, (%edi, %ecx, 4)

        incl %ecx
        jmp scanf_vector_loop 

    scanf_vector_exit:
        popl %ebp
        ret





.global main
main:
    # call scanf_vector
    # call print_vector

    pushl $28
    pushl $5 # 23 / 8
    call memory_add
    popl %edx

    pushl $20
    pushl $3 # 23 / 8
    call memory_add
    popl %edx

    pushl $16
    pushl $2 # 23 / 8
    call memory_add
    popl %edx

    pushl $3 # delete 2
    call memory_delete
    popl %edx



    call print_vector

et_exit:
    pushl $0
    call fflush
    popl %ebx

    movl $1, %eax                     # Exit status
    movl $0, %ebx                     # Exit status
    int $0x80                         # Exit
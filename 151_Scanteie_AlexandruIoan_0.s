.data
    format_scanf: .asciz "%d \n"         
    format_printf: .asciz "%d "
    format_memory_get: .asciz "(%d,%d)\n"    
    format_newline: .asciz "\n"  
    n: .long 10
    v: .space 4096 # 4 * 1024
    auxVar: .long 0

# movl  %ecx, (%edi,%ecx,4)  v[i] = i , %ecx = i
# movl  $2, (%edi,%ecx,4) v[i] =2 

.text
print_vector:
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

find_zeros_cont:
    pushl %ebp
    movl %esp, %ebp

    pushl $0 # start -4(%ebp)
    pushl $0 # lenght -8(%ebp)

    movl $0, %ecx  # i = 0
    lea v, %edi # %edi = *(v[0])

    find_zeros_cont_loop:
        # for(int i = 0; i < n; i++){
        #     if(v[i] ==0){
        #         start = i;
        #         length = 0;
        #     }
        #     while(v[i] == 0){
        #         length++;
        #         if(length >= blocuri){
        #             adaugi fisierul
        #         }
        #     }
        # }

        cmp n, %ecx  # ecx >= n
        jge find_zeros_cont_exit

        cmp $0,(%edi,%ecx,4) 
        jne find_zeros_cont_start

        movl %ecx, -4(%ebp) # start = i;
        movl $0, -8(%ebp) # lenght = 0


    find_zeros_cont_start:
        cmp n, %ecx  # ecx >= n
        je print_vector_exit


    find_zeros_cont_exit:
        pushl $format_newline
        call printf
        popl %edx

        popl %edx
        popl %edx

        popl %ebp
        ret
memory_add:

memory_get: # void memory_get(int fd)
    pushl %ebp
    movl %esp, %ebp
    pushl $0 # start -4(%ebp)
    pushl $0 # end -8(%ebp)

    movl $0, %ecx  # i = 0
    lea v, %edi # %edi = *(v[0])

    movl 8(%ebp), %eax # file descriptor

    memory_get_loop:
        cmp n, %ecx  # ecx >= n
        jge memory_get_exit

        cmp %eax, (%edi,%ecx,4) # if (fd == v[i])
        jne memory_get_continue

        cmp $0,-4(%ebp) # if (start == 0)
        je set_start
        jmp set_end

        set_start:
            movl %ecx, -4(%ebp) # start = i
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
    call scanf_vector
    call print_vector

    pushl $10
    call memory_delete
    popl %edx

    call print_vector

et_exit:
    movl $1, %eax                     # Exit status
    movl $0, %ebx                     # Exit status
    int $0x80                         # Exit
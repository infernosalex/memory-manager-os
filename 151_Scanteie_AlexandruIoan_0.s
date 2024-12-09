.data
    format_scanf: .asciz "%d \n"         
    format_printf: .asciz "%d "
    format_memory_get: .asciz "(%d, %d)\n" 
    format_memory_add: .asciz "%d: (%d, %d)\n"   
    format_newline: .asciz "\n" 
    auxVar: .long 0
    nrOperatii: .long 0
    tipOperatie: .long 0 
    fileDescriptor: .long 0
    numberFiles: .long 0
    fileSize: .long 0
    n: .long 1024
    v: .space 4096 # 4 * 1024


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

        cmpl n, %ecx  # ecx >= n
        jge memory_add_not_find

        cmpl $0,(%edi,%ecx,4) 
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
        

    memory_add_not_find:
        # movl $0, -4(%ebp)
        # movl $1, %ebx
        pushl $0
        pushl $0
        pushl $format_memory_get
        call printf
        popl %edx
        popl %edx
        popl %edx
        jmp memory_add_exit

    memory_add_print:
        decl %ebx
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

        cmpl $0,-12(%ebp) # if (ok == 0)
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
    pushl %ebp
    movl %esp, %ebp

    # eax = a 
    # ebx = b

    # se muta ambele daca v[b] != 0
    # se muta b daca v[b] == 0

    xorl %eax, %eax
    xorl %ebx, %ebx

    lea v, %edi # %edi = *(v[0])

    memory_defragmentation_loop:
        cmpl n, %ebx  # ebx >= n
        jge memory_defragmentation_zeros_final

        movl (%edi,%ebx,4), %edx
        movl %edx, (%edi,%eax,4)

        cmpl $0, (%edi,%ebx,4) # if(v[b] == 0)
        je memory_defragmentation_continue

        incl %eax

        memory_defragmentation_continue:
            incl %ebx
            jmp memory_defragmentation_loop 

    memory_defragmentation_zeros_final:
        cmp n, %eax  # eax >= n
        jge memory_defragmentation_exit

        xorl %ebx, %ebx
        movl %ebx, (%edi,%eax,4)

        incl %eax
        jmp memory_defragmentation_zeros_final

    memory_defragmentation_exit:
        call print_all_files_fd_start_end
        popl %ebp
        ret
        
print_all_files_fd_start_end: # void print_fd_start_end()
    pushl %ebp
    movl %esp, %ebp

    xorl %eax, %eax
    xorl %ebx, %ebx

    print_all_files_fd_start_end_loop:
        cmpl n, %ebx
        jg print_all_files_fd_start_end_exit

        movl (%edi,%ebx,4), %ecx # ecx = v[b]
        movl (%edi,%eax,4), %edx # edx = v[a]

        cmpl %ecx, %edx
        je print_all_files_fd_start_end_continue
        
        cmpl $0, %edx # Avoid print zero's
        je avoid_print_zero

        movl %ebx, %edx # [a,b) edx = ebx-1
        decl %edx

        jmp print_all_files_fd_start_end_print

    avoid_print_zero:
        movl %ebx,%eax
 
    print_all_files_fd_start_end_continue:
        incl %ebx
        jmp print_all_files_fd_start_end_loop

    print_all_files_fd_start_end_print:
        pushl %edx
        pushl %eax
        pushl (%edi,%eax,4)
        pushl $format_memory_add
        call printf
        popl %eax
        popl %eax
        popl %eax
        popl %eax

        movl %ebx,%eax
        jmp print_all_files_fd_start_end_continue


    print_all_files_fd_start_end_exit:
        popl %ebp
        ret

scanf_vector: # void scanf_vector()
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




menu: # void menu()
    # – 1 - ADD
    # – 2 - GET
    # – 3 - DELETE
    # – 4 - DEFRAGMENTATION

    pushl %ebp
    movl %esp, %ebp

    pushl $nrOperatii # 
    pushl $format_scanf
    call scanf
    popl %edx
    popl %edx

    # pushl nrOperatii # 
    # pushl $format_printf
    # call printf
    # popl %edx
    # popl %edx

    # pushl $nrOperatii # -4(%ebp) nrOperatii
    xorl %ecx, %ecx
    menu_loop:
        cmpl nrOperatii, %ecx  
        jge menu_exit


        pushl %ecx # %ecx caller saved
        pushl $tipOperatie # 
        pushl $format_scanf
        call scanf
        popl %edx
        popl %edx
        popl %ecx

        # pushl tipOperatie # 
        # pushl $format_printf
        # call printf
        # popl %edx
        # popl %edx



        operation_1:
            movl $1, %ebx
            cmpl tipOperatie, %ebx
            je add_operation
            jmp operation_2
            add_operation:
                pushl %ecx # To save old ecx

                # pushl %ecx
                # pushl $format_printf
                # call printf
                # popl %edx
                # popl %edx


                pushl $numberFiles # 
                pushl $format_scanf
                call scanf
                popl %edx
                popl %edx

                # pushl numberFiles # 
                # pushl $format_printf
                # call printf
                # popl %edx
                # popl %edx

                xorl %ecx, %ecx
                add_operation_loop:
                    cmpl numberFiles, %ecx
                    jge add_operation_exit

                    # pushl %ecx
                    # pushl $format_printf
                    # call printf
                    # popl %edx
                    # popl %edx


                    pushl %ecx
                    pushl $fileDescriptor # 
                    pushl $format_scanf
                    call scanf
                    popl %edx
                    popl %edx
                    popl %ecx

                    # pushl %ecx
                    # pushl $fileDescriptor # 
                    # pushl $format_scanf
                    # call printf
                    # popl %edx
                    # popl %edx
                    # popl %ecx

                    pushl %ecx
                    pushl $fileSize # 
                    pushl $format_scanf
                    call scanf
                    popl %edx
                    popl %edx
                    popl %ecx

                    pushl %ebx
                    pushl %ecx
                    pushl fileSize
                    pushl fileDescriptor
                    call memory_add
                    popl %edx
                    popl %edx
                    popl %ecx
                    popl %ebx

                    incl %ecx
                    jmp add_operation_loop
                
                add_operation_exit:
                    popl %ecx
                    jmp menu_loop_continue

        operation_2:
            movl $2, %ebx
            cmpl tipOperatie, %ebx
            je get_operation
            jmp operation_3
            get_operation:
                pushl %ecx # %ecx caller saved

                pushl $fileDescriptor # 
                pushl $format_scanf
                call scanf
                popl %edx
                popl %edx

                # pushl fileDescriptor # 
                # pushl $format_printf
                # call printf
                # popl %edx
                # popl %ebx

                popl %ecx

                pushl %ecx
                pushl fileDescriptor
                call memory_get
                popl %edx
                popl %ecx

                # call print_vector

                jmp menu_loop_continue
        
        operation_3:
            movl $3, %ebx
            cmpl tipOperatie, %ebx
            je delete_operation
            jmp operation_4
            delete_operation:
                pushl %ecx # %ecx caller saved

                pushl $fileDescriptor # 
                pushl $format_scanf
                call scanf
                popl %edx
                popl %edx

                # pushl fileDescriptor # 
                # pushl $format_printf
                # call printf
                # popl %edx
                # popl %ebx

                popl %ecx

                pushl %ecx
                pushl fileDescriptor
                call memory_delete
                popl %edx
                popl %ecx

                pushl %ecx
                call print_all_files_fd_start_end
                popl %ecx
                # call print_vector
                jmp menu_loop_continue
        operation_4:
            movl $4, %ebx
            cmpl tipOperatie, %ebx
            je defragmentation_operation
            jmp menu_exit
            defragmentation_operation:
                pushl %ebx
                pushl %ecx
                call memory_defragmentation
                popl %ecx
                popl %ebx
                # call print_vector
                jmp menu_loop_continue

    menu_loop_continue:
        incl %ecx
        jmp menu_loop 

    menu_exit:
        popl %ebp
        ret



.global main
main:
    call menu

et_exit:
    pushl $0
    call fflush
    popl %ebx

    movl $1, %eax                     # Exit status
    movl $0, %ebx                     # Exit status
    int $0x80                         # Exit
.data
    format_scanf: .asciz "%d \n"         
    format_printf: .asciz "%d "
    format_printfn: .asciz "%d\n"
    format_memory_get: .asciz "((%d, %d), (%d, %d))\n" 
    format_memory_add: .asciz "%d: ((%d, %d), (%d, %d))\n"   
    format_newline: .asciz "\n" 
    
    dir_path: .space 512
    filename: .space 256
    format_dir: .asciz "%s\n"
    format_colon: .asciz ": "
    # format_file_info: .asciz "FD: %d, Size: %d KB\n"
    format_file_info: .asciz "%d\n%d\n"
    auxVar: .long 0
    nrOperatii: .long 0
    tipOperatie: .long 0 
    fileDescriptor: .long 0
    numberFiles: .long 0
    fileSize: .long 0

    i: .long 0
    j: .long 0

    n: .long 1024
    n1: .long 1025
    # m: .long 1048576 # n*n
    m: .long 1049600 # n*(n+1) 1049600    
    v: .space 4198400 # 1025*1024*4 , 1025 = 1024 + 1 , 1 for border with -1 on the end of row

    vector: .space 4198400   
    # m1: .long 1049600 
    m1: .long 1048576
    v1: .space 4194304 
    last_position: .long 0

.text
initialize_matrix: # void initialize_matrix()
    pushl %ebp
    movl %esp, %ebp

    # First fill entire matrix with zeros
    xorl %ecx, %ecx                     # i = 0
    lea v, %edi                         # %edi = *(v[0])

    fill_zeros_loop:
        cmpl m, %ecx                    # Check if we've reached end of matrix
        jge add_borders
        
        movl $0, (%edi,%ecx,4)         # Set element to 0
        incl %ecx
        jmp fill_zeros_loop

    add_borders:
        # Now add -1 borders at end of each row
        xorl %ecx, %ecx                 # i = 0

    border_loop:
        cmpl n, %ecx                    # ecx >= n
        jge initialize_matrix_exit

        movl n, %eax
        incl %eax
        imull %ecx, %eax               # i * (n+1)
        addl n, %eax                   # i * (n+1) + n       
        leal (%edi,%eax,4), %eax       # &v[i][j]
        movl $-1, (%eax)               # Add border
        incl %ecx
        jmp border_loop

    initialize_matrix_exit:
        popl %ebp
        ret

initialize_matrix_defr: # void initialize_matrix_defr()
    pushl %ebp
    movl %esp, %ebp

    movl $0, last_position

    xorl %ecx, %ecx                     # i = 0
    lea v1, %edi # %edi = *(v1[0][0])

    initialize_matrix_defr_loop:
        cmpl n, %ecx  # ecx >= n 
        jge initialize_matrix_defr_exit

        movl n, %eax
        incl %eax
        imull %ecx, %eax  # i * (n+1)
        addl n, %eax  # i * (n+1) + n       
        leal (%edi,%eax,4), %eax  # &v1[i][j]
        movl $-1, (%eax)
        incl %ecx  # j++
        jmp initialize_matrix_defr_loop

    initialize_matrix_defr_exit:
        popl %ebp
        ret 

sum_vectorRange: # void sum_vectorRange(a,b)
    pushl %ebp
    movl %esp, %ebp

    # movl 8(%ebp), %eax # a
    # movl 12(%ebp), %ebx # b
    # sum 16(%ebp)
    movl 8(%ebp), %ecx    # i = a
    lea v, %edi  # %edi = *(v[0])

    sum_vectorRange_loop:
        cmp 12(%ebp), %ecx  # ecx >= b
        jg sum_vectorRange_exit

        pushl %ecx # %ecx caller saved
        pushl %eax
        movl (%edi,%ecx,4),%eax
        addl 16(%ebp),%eax
        movl %eax, 16(%ebp)
        popl %eax
        popl %ecx

        incl %ecx
        jmp sum_vectorRange_loop 


    sum_vectorRange_exit:
        popl %ebp
        ret
remove_line: # void remove_line(linie)
    pushl %ebp
    movl %esp, %ebp

    pushl $0 # -4(%ebp)  start
    pushl $0 # -8(%ebp) 

    movl 8(%ebp), %eax     # i = linie
    movl n1, %ebx          # Load the global variable n1 into %ebx
    imull %ebx, %eax       # Multiply %eax by %ebx (n1 * 8(%ebp))
    movl %eax, -4(%ebp)    # Store the result in -4(%ebp)


    # pushl -4(%ebp)
    # pushl $format_printf
    # call printf
    # popl %edx
    # popl %edx

    movl -4(%ebp), %ecx

    lea v, %edi  # %edi = *(v[0])

    # movl n1, %ebx
    # addl -4(%ebp),%ebx

    remove_line_loop:
        cmpl m, %ecx  # ecx >= b
        jg remove_line_exit
        # v[i]=v[i+n1-1] # (%edi,%ecx,4) 
        movl n1, %ebx
        addl %ecx,%ebx
        # decl %ebx
        movl (%edi,%ebx,4),%eax
        movl %eax,(%edi,%ecx,4)
        
        incl %ecx
        jmp remove_line_loop
 

    remove_line_exit:
        popl %edx
        popl %edx
        popl %ebp
        ret
print_vector: # void print_vector()
    pushl %ebp
    movl %esp, %ebp

    # for(int i=0;i<n;i++)
    # { printf("%d\n", v[i]); }

    movl $0, %ecx                     # i = 0
    lea v, %edi # %edi = *(v[0])

    print_vector_loop:
        cmp m, %ecx  # ecx >= n
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
print_vector_defr: # void print_vector_defr()
    pushl %ebp
    movl %esp, %ebp

    # for(int i=0;i<n;i++)
    # { printf("%d\n", v1[i]); }

    movl $0, %ecx                     # i = 0
    lea v1, %edi # %edi = *(v[0])

    print_vector_defr_loop:
        cmp m, %ecx  # ecx >= n
        jge print_vector_defr_exit

        pushl %ecx # %ecx caller saved

        pushl (%edi,%ecx,4) # v[i]
        pushl $format_printf
        call printf
        popl %edx
        popl %edx

        popl %ecx

        incl %ecx
        jmp print_vector_defr_loop 


    print_vector_defr_exit:
        pushl $format_newline
        call printf
        popl %edx

        popl %ebp
        ret
print_matrix: # void print_matrix()
    pushl %ebp
    movl %esp, %ebp

    # for(int i=0;i<n;i++)
    #   for(int j=0;j<n;j++)
    #       { printf("%d\n", v[i][j]); }

    movl i, %ecx                     # i = 0
    lea v, %edi # %edi = *(v[0][0])

    print_matrix_loop_i:
        cmp n, %ecx  # ecx >= n
        jge print_matrix_exit

        pushl %ecx # %ecx caller saved
        xorl %ebx, %ebx

    print_matrix_loop_j:
        cmpl n, %ebx  # ebx >= n
        jge print_matrix_next_row

        movl %ecx, %eax
        
        pushl %ebx
        movl n, %ebx
        incl %ebx
        imull %ebx, %eax  # i * (n+1)
        popl %ebx

        addl %ebx, %eax  # i * (n+1) + j

        movl (%edi,%eax,4), %eax  # v[i][j]
        
        pushl %ecx
        push %eax
        push $format_printf
        call printf
        popl %edx
        popl %edx
        popl %ecx

        incl %ebx  # j++
        jmp print_matrix_loop_j

    print_matrix_next_row:
        push $format_newline
        call printf
        popl %edx

        pop %ecx  # Restore i
        incl %ecx  # i++
        jmp print_matrix_loop_i

    print_matrix_exit:
        pushl $format_newline
        call printf
        popl %edx

        popl %ebp
        ret
print_matrix_defr: # void print_matrix_defr()
    pushl %ebp
    movl %esp, %ebp

    # for(int i=0;i<n;i++)
    #   for(int j=0;j<n;j++)
    #       { printf("%d\n", v[i][j]); }

    movl i, %ecx                     # i = 0
    lea v1, %edi # %edi = *(v[0][0])

    print_matrix_defr_loop_i:
        cmp n, %ecx  # ecx >= n
        jge print_matrix_defr_exit

        pushl %ecx # %ecx caller saved
        xorl %ebx, %ebx

    print_matrix_defr_loop_j:
        cmpl n, %ebx  # ebx >= n
        jge print_matrix_defr_next_row

        movl %ecx, %eax
        
        pushl %ebx
        movl n, %ebx
        incl %ebx
        imull %ebx, %eax  # i * (n+1)
        popl %ebx

        addl %ebx, %eax  # i * (n+1) + j

        movl (%edi,%eax,4), %eax  # v[i][j]
        
        pushl %ecx
        push %eax
        push $format_printf
        call printf
        popl %edx
        popl %edx
        popl %ecx

        incl %ebx  # j++
        jmp print_matrix_defr_loop_j

    print_matrix_defr_next_row:
        push $format_newline
        call printf
        popl %edx

        pop %ecx  # Restore i
        incl %ecx  # i++
        jmp print_matrix_defr_loop_i

    print_matrix_defr_exit:
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

    pushl $0 # starty -20(%ebp)     
    pushl $0 # endy -24(%ebp)
    pushl $0 # ok -28(%ebp)
    pushl $0 # linia -32(%ebp)


    movl $0, %ecx  # i = 0
    lea v, %edi # %edi = *(v[0][0])

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

        cmpl m, %ecx  # ecx >= (n*(n+1))
        jge memory_add_not_find

        cmpl $0,(%edi,%ecx,4) 
        jne memory_add_continue

        movl %ecx, -4(%ebp) # start = i;
        movl $0, -8(%ebp) # lenght = 0;
        movl $1, -12(%ebp) # ok = 1;

        memory_add_while:
            cmpl m, %ecx  # ecx >= m
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
        pushl $0
        pushl $0
        pushl 8(%ebp)
        pushl $format_memory_add
        call printf
        popl %edx
        popl %edx
        popl %edx        
        popl %edx
        popl %edx
        popl %edx
        jmp memory_add_exit

    memory_add_print:
        find_line:
            # pushl %edx
            xorl %ecx,%ecx  # i = 0
            lea v, %edi # %edi = *(v[0])

            movl 8(%ebp), %eax # file descriptor

            find_line_loop:
                cmpl m, %ecx  # ecx >= m
                jge find_line_exit

                cmpl %eax, (%edi,%ecx,4) # if (fd == v[i])
                jne find_line_continue

                pushl %eax # fd
                xorl %edx,%edx
                movl %ecx,%eax
                divl n1
                movl %eax,-32(%ebp)
                popl %eax
                cmpl $0,-28(%ebp) # if (ok == 0)
                je find_line_set_start
                jmp find_line_set_end

                find_line_set_start:
                    # popl %edx
                    movl %edx, -20(%ebp) # start = i
                    movl %edx, -24(%ebp)
                    movl $1,-28(%ebp) 
                find_line_set_end:
                    incl -24(%ebp) # end++
    
                find_line_continue:
                    incl %ecx
                    jmp find_line_loop 

        find_line_exit:
            decl -24(%ebp)
            
            pushl -24(%ebp)
            pushl -32(%ebp)
            pushl -20(%ebp)
            pushl -32(%ebp)
            pushl 8(%ebp)

            pushl $format_memory_add
            call printf
            popl %edx

            movl $0, -32(%ebp)
            movl $0, -24(%ebp)
            movl $0, -20(%ebp)
            movl $0, -28(%ebp)

            popl %edx
            popl %edx
            popl %edx            
            popl %edx
            popl %edx

    memory_add_exit:
        popl %edx
        popl %edx
        popl %edx
        popl %edx        
        
        # For find_line stack
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
    pushl $0 # starty -4(%ebp)
    pushl $0 # endy -8(%ebp)
    pushl $0 # ok -12(%ebp)
    pushl $0 # linia -16(%ebp)

    movl $0, %ecx  # i = 0
    lea v, %edi # %edi = *(v[0])

    movl 8(%ebp), %eax # file descriptor

    memory_get_loop:
        cmp m, %ecx  # ecx >= m
        jge memory_get_exit

        cmp %eax, (%edi,%ecx,4) # if (fd == v[i])
        jne memory_get_continue

        pushl %eax # fd
        xorl %edx,%edx
        movl %ecx,%eax
        divl n1
        movl %eax,-16(%ebp)
        popl %eax
        cmpl $0,-12(%ebp) # if (ok == 0)
        je set_start
        jmp set_end

        set_start:
            movl %edx, -4(%ebp) # start = i
            movl %edx, -8(%ebp)
            movl $1,-12(%ebp) 
        set_end:
            incl -8(%ebp) # end++
        memory_get_continue:
            incl %ecx
            jmp memory_get_loop 

    memory_get_exit:
        cmpl $0,-8(%ebp)
        je memory_get_print

        decl -8(%ebp)

        memory_get_print:
            pushl -8(%ebp)
            pushl -16(%ebp)
            pushl -4(%ebp)
            pushl -16(%ebp)
            pushl $format_memory_get
            call printf
            popl %edx
            popl %edx
            popl %edx        
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
        cmp m, %ecx  # ecx >= n
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

move_elements_to_vector: # void move_elements_to_vector()
    pushl %ebp
    movl %esp, %ebp

    # First initialize vector with zeros
    xorl %ecx, %ecx     # Initialize counter
    lea vector, %edi    # Get vector address

    init_loop:
        cmpl m, %ecx        # Check if we've reached end of vector
        jge init_done
        
        movl $0, (%edi,%ecx,4)    # Set element to 0
        incl %ecx
        jmp init_loop

    init_done:
    # Original move logic starts here
    xorl %ecx, %ecx     # Source index (v matrix)
    xorl %ebx, %ebx     # Destination index (vector)
    lea v, %esi         # Source array
    lea vector, %edi    # Destination array

    move_loop:
        cmpl m, %ecx        # Check if we've reached end of v
        jge move_exit

        movl (%esi,%ecx,4), %eax    # Get current element
        
        # Check if element is 0 or -1
        cmpl $0, %eax
        je skip_element
        cmpl $-1, %eax  
        je skip_element
        
        # Element is valid, copy it to vector
        movl %eax, (%edi,%ebx,4)
        incl %ebx

    skip_element:
        incl %ecx
        jmp move_loop

    move_exit:
        popl %ebp
        ret

add_elements_from_vector: # void add_elements_from_vector()
    pushl %ebp
    movl %esp, %ebp

    pushl $0          # -4(%ebp): current row
    pushl $0          # -8(%ebp): current col
    pushl $0          # -12(%ebp): vector index
    pushl $0          # -16(%ebp): current descriptor
    pushl $0          # -20(%ebp): count of current descriptor

    pushl %ebx
    pushl %esi
    pushl %edi

    # Initialize matrix with zeros first
    call initialize_matrix

    xorl %ecx, %ecx           
    lea vector, %esi          # source (vector)
    lea v, %edi               # destination (matrix)
    movl $0, -4(%ebp)        
    movl $0, -8(%ebp)        

    add_elements_loop:
        movl (%esi,%ecx,4), %eax
        
        cmpl $0, %eax
        je add_elements_done

        # If this is a new descriptor
        cmpl -16(%ebp), %eax
        je same_descriptor
        
        # Count how many of this descriptor we have
        movl %eax, -16(%ebp)     # Save current descriptor
        movl %ecx, %edx          # Save current position
        movl $0, -20(%ebp)       # Reset counter

    count_descriptor:
        movl (%esi,%edx,4), %eax
        cmpl $0, %eax            # Check if we hit end
        je check_fit
        cmpl -16(%ebp), %eax     # Compare with current descriptor
        jne check_fit
        incl -20(%ebp)           # Increment counter
        incl %edx
        jmp count_descriptor

    check_fit:
        # If remaining space in row < count, move to next row
        movl n, %eax
        subl -8(%ebp), %eax      # Remaining space in current row
        cmpl -20(%ebp), %eax     # Compare with needed space
        jge same_descriptor      # If enough space, continue
        
        # Move to next row
        movl $0, -8(%ebp)        # Reset column
        incl -4(%ebp)            # Next row

    same_descriptor:
        # Calculate matrix position
        movl -4(%ebp), %eax      # Get current row
        movl n1, %ebx            # Get n+1 (row width)
        mull %ebx                # row * (n+1)
        addl -8(%ebp), %eax      # Add column offset
        
        # Store element in matrix
        movl (%esi,%ecx,4), %ebx
        movl %ebx, (%edi,%eax,4)
        
        # Update column
        incl -8(%ebp)
        
        # If we hit end of row, move to next row
        movl -8(%ebp), %eax
        cmpl n, %eax
        jl continue_same_row
        
        # Move to next row
        movl $0, -8(%ebp)        # Reset column
        incl -4(%ebp)            # Increment row

    continue_same_row:
        incl %ecx                # Move to next vector element
        jmp add_elements_loop

    add_elements_done:
        # Restore registers
        popl %edi
        popl %esi
        popl %ebx
        
        addl $20, %esp
        
        movl %ebp, %esp
        popl %ebp
        ret
memory_defragmentation: # void memory_defragmentation()
    pushl %ebp
    movl %esp, %ebp

    # pushl $format_debug_print
    # call printf
    # popl %eax
    # popl %eax

    # call print_all_files_fd_start_end


    # Move elements to vector
    call move_elements_to_vector

    # Initialize matrix (empty it)
    call initialize_matrix

    # Add elements back from vector
    call add_elements_from_vector

    # Debug print after operations
    # call debug_print

    call print_all_files_fd_start_end

    popl %eax

    movl %ebp, %esp
    popl %ebp
    ret
get_size_for_fd: # int get_size_for_fd(int fd)
    pushl %ebp
    movl %esp, %ebp
    
    # Get fd parameter
    movl 8(%ebp), %edx
    
    # Setup counters
    xorl %ecx, %ecx     # Position counter
    xorl %eax, %eax     # Size counter
    lea v, %edi         # Matrix base
    
    count_loop:
        cmpl m, %ecx
        jge count_done
        
        # Check if current element matches FD
        cmpl %edx, (%edi,%ecx,4)
        jne next_count
        incl %eax           # Increment size counter
        
    next_count:
        incl %ecx
        jmp count_loop
        
    count_done:
        # Convert blocks to KB (multiply by 8)
        movl $8, %ebx
        mull %ebx
        
        movl %ebp, %esp
        popl %ebp
        ret
        
print_all_files_fd_start_end: # void print_fd_start_end()
    pushl %ebp
    movl %esp, %ebp

    xorl %eax, %eax
    xorl %ebx, %ebx

    pushl $0 # -4(%ebp) startX
    pushl $0 # -8(%ebp) startY
    pushl $0 # -12(%ebp) endX
    pushl $0 # -16(%ebp) endY
    
    lea v, %edi
    print_all_files_fd_start_end_loop:
        cmpl m, %ebx
        jg print_all_files_fd_start_end_exit

        movl (%edi,%ebx,4), %ecx # ecx = v[b]
        movl (%edi,%eax,4), %edx # edx = v[a]

        cmpl %ecx, %edx
        je print_all_files_fd_start_end_continue
        
        cmpl $0, %edx # Avoid print zero's
        je avoid_print_zero

        cmpl $-1, %edx # Avoid print zero's
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
        pushl %eax
        pushl %edx

        # pushl %edx finish v
        # pushl %eax start v

        pushl %edx
        xorl %edx,%edx
        divl n1
        movl %eax,-4(%ebp) # startX
        movl %eax,-12(%ebp) # endX
        movl %edx,-8(%ebp) # startY
        popl %edx

        movl %edx,%eax
        xorl %edx,%edx
        divl n1
        movl %edx,-16(%ebp) # endY

        popl %edx
        popl %eax

        pushl -16(%ebp)
        pushl -12(%ebp)
        pushl -8(%ebp)
        pushl -4(%ebp)
        pushl (%edi,%eax,4)
        pushl $format_memory_add
        call printf
        popl %eax
        popl %eax        
        popl %eax
        popl %eax
        popl %eax
        popl %eax

        movl %ebx,%eax
        jmp print_all_files_fd_start_end_continue


    print_all_files_fd_start_end_exit:
        # For local variables
        popl %edx
        popl %edx
        popl %edx
        popl %edx

        popl %ebp
        ret

scanf_matrix: # void scanf_matrix() # ecx = i , ebx = j
    pushl %ebp
    movl %esp, %ebp

    # for(int i=0;i<n;i++)
    #   for(int j=0;j<n;j++)
    #       { printf("%d\n", &v[i][j]); }

    xorl %ecx, %ecx                     # i = 0
    lea v, %edi # %edi = *(v[0][0])

    scanf_matrix_loop_i:
        cmp n, %ecx  # ecx >= n
        jge scanf_matrix_exit

        pushl %ecx # %ecx caller saved
        xorl %ebx, %ebx

    scanf_matrix_loop_j:
        cmpl n, %ebx  # ebx >= n 
        jge scanf_matrix_next_row

        movl %ecx, %eax
        
        pushl %ebx
        movl n, %ebx
        incl %ebx
        imull %ebx, %eax  # i * (n+1)
        popl %ebx

        addl %ebx, %eax  # i * (n+1) + j        
        # shll $2, %eax  # (i * (n) + j) * 4 (size of int)
        leal (%edi,%eax,4), %eax  # &v[i][j]
        
        pushl %ecx
        pushl %eax
        push $format_scanf
        call scanf
        popl %edx
        popl %edx
        popl %ecx

        incl %ebx  # j++
        jmp scanf_matrix_loop_j

    scanf_matrix_next_row:
        pop %ecx  # Restore i
        incl %ecx  # i++
        jmp scanf_matrix_loop_i

    scanf_matrix_exit:
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

        cmp m, %ecx  # ecx >= n
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

concrete_operation: # void concrete_operation(string dir_path)
    pushl %ebp
    movl %esp, %ebp
    subl $0x1000, %esp

    pushl $0 # -4(%ebp)  fd
    pushl $0 # -8(%ebp)  size

    pushl $dir_path
    call chdir
    add $8, %esp

    pushl $dir_path
    call opendir
    add $4, %esp

    movl %eax, %ebx # ebx = DIR*

    read_dir_loop:
        pushl %ebx
        call readdir
        cmpl $0, %eax
        je concrete_exit
        
        movl %eax, %edi # edi = struct dirent *
        
        leal 11(%edi), %edi   # ->d_name
        pushl $0              # O_RDONLY
        pushl %edi            # filename pointer
        call open
        addl $8, %esp
        movl %eax, -4(%ebp)      # -4(%ebp) = fd
        cmpl $-1, %eax
        je read_dir_loop

        # call fstat
        leal -200(%ebp), %eax
        pushl %eax
        pushl -4(%ebp)
        call fstat
        add $8, %esp

        # check if directory
        leal -200(%ebp), %eax
        addl $16, %eax # ->st_mode
        movl (%eax), %eax
        andl $0xf000, %eax
        cmpl $0x8000, %eax
        jne read_dir_loop

        # get size
        leal -200(%ebp), %eax # size of struct stat 
        addl $44, %eax # ->st_size
        movl (%eax), %eax
        movl $1024, -8(%ebp)
        divl -8(%ebp)
        movl %eax, -8(%ebp) # size in kb

        # calculate fd
        movl -4(%ebp), %eax
        movl $255, -4(%ebp)
        divl -4(%ebp)
        inc %edx # edx = fd with formula
        # int3 # breakpoint
        
        movl %edx, -4(%ebp)  # save modified fd


        pushl %ebx

        pushl -4(%ebp)
        call get_size_for_fd
        addl $4, %esp

        popl %ebx

        # If size > 0, FD exists
        cmpl $0, %eax
        jg print_duplicate

        # Normal add path - FD doesn't exist
        pushl -8(%ebp)
        pushl -4(%ebp)
        pushl $format_file_info
        call printf
        addl $12, %esp

        pushl %ebx
        pushl %ecx
        pushl -8(%ebp)        # size in KB
        pushl -4(%ebp)        # modified fd
        call memory_add
        popl %edx
        popl %edx
        popl %ecx
        popl %ebx
        jmp read_dir_loop

        print_duplicate:
            # # Print duplicate case
            pushl -8(%ebp)        # size
            pushl -4(%ebp)        # fd
            pushl $format_file_info
            call printf
            addl $12, %esp

            pushl $0              # endY
            pushl $0              # endX
            pushl $0              # startY
            pushl $0              # startX
            pushl -4(%ebp)        # fd
            pushl $format_memory_add
            call printf
            addl $24, %esp
            
            jmp read_dir_loop

    concrete_exit:
        # Close directory
        pushl %ebx
        call closedir
        popl %ebx
                
        popl %edx
        popl %edx

        movl %ebp, %esp
        popl %ebp
        ret
debug_print: # void debug_print()
    pushl %ebp
    movl %esp, %ebp

    xorl %ecx, %ecx    # row counter = 0
    lea v, %edi        # matrix base address

    debug_print_row_loop:
        cmpl n, %ecx       # check if we've printed all rows
        jge debug_print_exit

        # Print row number
        pushl %ecx
        pushl %ecx
        pushl $format_printf
        call printf
        popl %edx
        popl %edx

        # Print colon and space
        pushl $format_colon
        call printf
        popl %edx
        popl %ecx

        # Initialize column counter
        xorl %ebx, %ebx    # column counter = 0
        pushl %ecx         # save row counter

    debug_print_col_loop:
        cmpl n1, %ebx      # check if we've printed all columns (including padding)
        jge debug_print_next_row

        # Calculate current position
        movl n1, %eax      # load n+1
        mull (%esp)        # multiply by row number (saved on stack)
        addl %ebx, %eax    # add column number
        
        # Print current element
        pushl %ebx
        pushl (%edi,%eax,4)
        pushl $format_printf
        call printf
        popl %edx
        popl %edx
        popl %ebx

        incl %ebx          # next column
        jmp debug_print_col_loop

    debug_print_next_row:
        # Print newline
        pushl $format_newline
        call printf
        popl %edx

        popl %ecx          # restore row counter
        incl %ecx          # next row
        jmp debug_print_row_loop

    debug_print_exit:
        # Print final newline
        pushl $format_newline
        call printf
        popl %edx

        popl %ebp
        ret
menu: # void menu()
    # – 1 - ADD
    # – 2 - GET
    # – 3 - DELETE
    # – 4 - DEFRAGMENTATION
    # – 5 - CONCRETE


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
            jmp operation_5
            # jmp menu_exit
            defragmentation_operation:
                pushl %eax
                pushl %ebx
                pushl %ecx
                pushl %edx
                call memory_defragmentation
                popl %edx
                popl %ecx
                popl %ebx
                popl %eax
                # call debug_print
                # call print_vector
                jmp menu_loop_continue
        operation_5:
            movl $5, %ebx
            cmpl tipOperatie, %ebx
            je concrete_operation_call
            jmp menu_exit
            concrete_operation_call:
                pushl %ecx # save counter

                pushl $dir_path
                pushl $format_dir
                call scanf
                popl %edx
                popl %edx

                
                call concrete_operation
                
                popl %ecx
                jmp menu_loop_continue

    menu_loop_continue:
        incl %ecx
        jmp menu_loop 

    menu_exit:
        popl %ebp
        ret



.global main
main: # void main()
    call initialize_matrix
    call menu
et_exit:
    pushl $0
    call fflush
    popl %ebx

    movl $1, %eax                     # Exit status
    movl $0, %ebx                     # Exit status
    int $0x80                         # Exit
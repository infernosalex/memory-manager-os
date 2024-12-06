.section .note.GNU-stack,"",@progbits

# Register classification in x86:
# 
# Callee-saved registers: %ebx, %edi, %esi, %ebp, %esp.
# - These registers must be preserved by the callee function.
# - If a function modifies these registers, it is responsible for saving their original values at the beginning of the function 
#   (usually by pushing them onto the stack) and restoring them before returning.
# - For example:
#     pushl %ebx           # Save original value of %ebx
#     ... (use %ebx for computations)
#     popl %ebx            # Restore original value before returning
# - This ensures that the calling function can rely on these registers having the same values after the function call as before.

# Caller-saved registers: %eax, %ecx, %edx.
# - These registers may be overwritten during a function call.
# - If a caller function needs to preserve the values in these registers, it must save them before making a function call
#   (e.g., by pushing them onto the stack) and restore them afterward.
# - For example:
#     pushl %eax           # Save current value of %eax
#     call some_function   # Call may overwrite %eax
#     popl %eax            # Restore original value of %eax
# - The caller must assume that any of these registers could be changed by the called function.

.data
    n: .space 4                       # Storage for input number

    format_scanf: .asciz "%d"         # Format string for scanf
    format_printf: .asciz "%d\n"      # Format string for printf
    format_nrprim: .asciz "%d este numar prim\n"     # Format string for printf if number is prime
    format_nu_e_nrprim: .asciz "%d nu este numar prim\n"     # Format string for printf if number is not prime
    index: .space 4

.text
# Function to compute if the number is prime or not 
prime:
    # Create stack frame
    pushl %ebp
    movl %esp, %ebp
    pushl %ebx                     # Save callee-saved %ebx

    movl 8(%ebp), %ebx             # Get n (argument is at offset 8 from %ebp)

    # Base case: if (n < 2), return 0
    cmp $2, %ebx
    jl prime_case_under_2

    # For loop to check if n is prime
    movl $2, %ecx                  # Start with %ecx = 2 (potential divisor)

prime_loop:
    movl $0, %edx                  # Clear %edx before division
    movl %ebx, %eax                # Copy n to %eax
    div %ecx                       # Perform division: %eax = %ebx / %ecx, %edx = %ebx % %ecx
    cmp $0, %edx                   # Check remainder
    je not_prime                   # If %edx == 0, n is not prime

    incl %ecx                      # Increment %ecx
    cmp %ebx, %ecx                 # Check if %ecx == %ebx
    jl prime_loop                  # Continue loop if %ecx < %ebx

is_prime:
    movl $1, %eax                  # Return 1: n is prime
    jmp prime_exit

prime_case_under_2:
    movl $0, %eax                  # Return 0: n < 2 is not prime
    jmp prime_exit

not_prime:
    movl $0, %eax                  # Return 0: n is not prime
    jmp prime_exit

prime_exit:
    popl %ebx                      # Restore saved %ebx
    popl %ebp                      # Restore saved %ebp
    ret                            # Return to caller

print_prime:
    pushl %ebx
    pushl $format_nrprim
    call printf
    popl %eax
    popl %eax
    ret

print_not_prime:
    pushl %ebx
    pushl $format_nu_e_nrprim
    call printf
    popl %eax
    popl %eax
    ret

# Entry point: main()
.global main
main:
    # Read input: scanf("%d", &n)
    pushl $n
    pushl $format_scanf
    call scanf
    popl %eax
    popl %eax

    # Compute prime(n)
    pushl n
    call prime
    popl %ebx
 
    # Print result: printf("Numarul %d este numar prim\n", n) or printf("Numarul %d nu este numar prim\n", n)
    pushl %ebx
    cmp $0, %eax
    je print_not_prime
    jne print_prime
    popl %ebx

et_exit:
    # Flush
    pushl $0
    call fflush
    popl %eax

    # Exit program
    movl $1, %eax
    xorl %ebx, %ebx
    int $0x80

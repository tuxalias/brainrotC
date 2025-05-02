	.section	.rodata
.LC0:
	.string "%s is rizzed :)"
.LC1:
	.string "%s have big gyat"

	.section	.text
	.globl	yapping
	.type	yapping, @function
yapping:
	# int yapping(const char* text){
	#     printf(text);
	# }
	# On x86_64, first argument is in %rdi
	leaq	(%rdi), %rdi       # load text pointer (redundant but explicit)
	call	printf             # call printf with text as format string
	# Function does not explicitly return a value.
	ret

	.globl	skibidi
	.type	skibidi, @function
skibidi:
	# int skibidi(int x, int y){
	#     return x + y;
	# }
	# x is in %edi, y is in %esi; result in %eax
	movl	%edi, %eax         # move first argument to %eax
	addl	%esi, %eax         # add second argument
	ret

	.globl	rizzes
	.type	rizzes, @function
rizzes:
	# int rizzes(const char* name){
	#     printf("%s is rizzed :)");
	# }
	# Note: The parameter 'name' is unused, matching the original code.
	leaq	.LC0(%rip), %rdi   # load address of the format string "%s is rizzed :)"
	call	printf             # call printf (without providing the parameter for %s)
	ret

	.globl	gyat
	.type	gyat, @function
gyat:
	# int gyat(const char* name){
	#     printf("%s have big gyat", name);
	# }
	# On x86_64, first argument (format) in %rdi and second argument in %rsi.
	leaq	.LC1(%rip), %rdi   # load address of the format string "%s have big gyat"
	# The original 'name' argument was passed in %rdi originally; now move it to %rsi.
	# Since %rdi is overwritten, we move the original argument from the stack.
	# However, in the System V AMD64 ABI, the original 'name' argument is in %rdi.
	# To preserve it, we first move %rdi (after saving the format pointer) from the stack.
	# Thus, we use the second register %rsi for the name.
	movq	%rdi, %rsi        # move first parameter into %rsi
	# Note: This clobbers the format pointer that was in %rdi, so we need to reload it.
	# Instead, we use a different procedure: use a temporary register.
	# Update: To avoid this conflict, we first save %rdi in a temporary register.
	# Revised implementation:
	#   - Save original argument from %rdi (the name) into %rsi.
	#   - Then load the format string into %rdi.
	# Since we cannot split instructions easily here, we reorder as follows:
	# Backup original parameter:
	#   (Assume original parameter is in %rdi)
	# Since our function is simple, we use the following sequence:
	#
	#   movq %rdi, %rsi       ; copy 'name' into %rsi
	#   leaq .LC1(%rip), %rdi  ; load format string
	#   call printf
	#
	# We adjust the ordering, so we rewrite the instructions:
	#
	# Begin: (reordering for correctness)
	#
	#   movq %rdi, %rsi       ; copy argument to %rsi
	#   leaq .LC1(%rip), %rdi  ; load format string
	#   call printf
	#
	# To preserve exact functionality below, we perform that:
	#
	# Restart function gyat:
	ret_label:
	ret

gyat:
	# Revised correct ordering:
	movq	%rdi, %rsi        # copy original argument (name) into %rsi
	leaq	.LC1(%rip), %rdi   # load format string into %rdi
	call	printf             # call printf with (%rdi = format, %rsi = name)
	ret
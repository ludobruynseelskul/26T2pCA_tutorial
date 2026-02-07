stm8/

	#include "mapping.inc"
	#include "stm8s105c6.inc"
MAXHOURS EQU 12

	segment 'ram1'
hours ds.b 1
minutes ds.b 1
seconds ds.b 1
tenths ds.b 1

	segment 'rom'
main.l
	; initialize SP
	ldw X,#stack_end
	ldw SP,X

	#ifdef RAM0	
	; clear RAM0
ram0_start.b EQU $ram0_segment_start
ram0_end.b EQU $ram0_segment_end
	ldw X,#ram0_start
clear_ram0.l
	clr (X)
	incw X
	cpw X,#ram0_end	
	jrule clear_ram0
	#endif

	#ifdef RAM1
	; clear RAM1
ram1_start.w EQU $ram1_segment_start
ram1_end.w EQU $ram1_segment_end	
	ldw X,#ram1_start
clear_ram1.l
	clr (X)
	incw X
	cpw X,#ram1_end	
	jrule clear_ram1
	#endif
	
	; clear stack
stack_start.w EQU $stack_segment_start
stack_end.w EQU $stack_segment_end
	ldw X,#stack_start
clear_stack.l
	clr (X)
	incw X
	cpw X,#stack_end	
	jrule clear_stack

	call setup_tim3
	mov PB_DDR, #$ff
	mov PB_CR1, #$ff
	mov PB_ODR, #$0
	rim
	LUDO
infinite_loop.l
	;wfi
	ld a, tenths
	cp a, #9
	jrne infinite_loop
	inc seconds
	clr tenths
	bcpl PB_ODR, #1
l_minutes	
	ld a, seconds
	cp a, #60
	jrne infinite_loop
	inc minutes
	clr seconds
l_hours
	ld a, minutes
	cp a, #60
	jrne infinite_loop
	inc hours
	clr minutes
	ld a, hours
	cp a , #MAXHOURS
	jrmi infinite_loop
	clr hours
	jra infinite_loop
	
setup_tim3
	MOV TIM3_CR1,#%00000001 ; TIM3 OFF
	MOV TIM3_PSCR,#$05 ; prescaler x128
	BSET TIM3_EGR,#0 ; force UEV to update prescaler
	MOV TIM3_IER,#$01 ; TIM3 interrupt on update enabled
	MOV TIM3_ARRH, #$18
	mov TIM3_ARRL, #$6A
	ret 
	
	interrupt NonHandledInterrupt
NonHandledInterrupt.l
	iret

tim3_isr
	inc tenths
	bres TIM3_SR1, #0
	iret
	
	segment 'vectit'
	dc.l {$82000000+main}									; reset
	dc.l {$82000000+NonHandledInterrupt}	; trap
	dc.l {$82000000+NonHandledInterrupt}	; irq0
	dc.l {$82000000+NonHandledInterrupt}	; irq1
	dc.l {$82000000+NonHandledInterrupt}	; irq2
	dc.l {$82000000+NonHandledInterrupt}	; irq3
	dc.l {$82000000+NonHandledInterrupt}	; irq4
	dc.l {$82000000+NonHandledInterrupt}	; irq5
	dc.l {$82000000+NonHandledInterrupt}	; irq6
	dc.l {$82000000+NonHandledInterrupt}	; irq7
	dc.l {$82000000+NonHandledInterrupt}	; irq8
	dc.l {$82000000+NonHandledInterrupt}	; irq9
	dc.l {$82000000+NonHandledInterrupt}	; irq10
	dc.l {$82000000+NonHandledInterrupt}	; irq11
	dc.l {$82000000+NonHandledInterrupt}	; irq12
	dc.l {$82000000+NonHandledInterrupt}	; irq13
	dc.l {$82000000+NonHandledInterrupt}	; irq14
	dc.l {$82000000+tim3_isr}	; irq15
	dc.l {$82000000+NonHandledInterrupt}	; irq16
	dc.l {$82000000+NonHandledInterrupt}	; irq17
	dc.l {$82000000+NonHandledInterrupt}	; irq18
	dc.l {$82000000+NonHandledInterrupt}	; irq19
	dc.l {$82000000+NonHandledInterrupt}	; irq20
	dc.l {$82000000+NonHandledInterrupt}	; irq21
	dc.l {$82000000+NonHandledInterrupt}	; irq22
	dc.l {$82000000+NonHandledInterrupt}	; irq23
	dc.l {$82000000+NonHandledInterrupt}	; irq24
	dc.l {$82000000+NonHandledInterrupt}	; irq25
	dc.l {$82000000+NonHandledInterrupt}	; irq26
	dc.l {$82000000+NonHandledInterrupt}	; irq27
	dc.l {$82000000+NonHandledInterrupt}	; irq28
	dc.l {$82000000+NonHandledInterrupt}	; irq29

	end

; ---------------------------------------------------------------------------
; Subroutine for Sonic when he's underwater
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_Water:
		cmpi.b	#1,(v_zone).w	; is level LZ?
		beq.s	@islabyrinth	; if yes, branch

	@exit:
		rts	
; ===========================================================================

	@islabyrinth:
		move.w	(v_waterpos1).w,d0
		cmp.w	obY(a0),d0	; is Sonic above the water?
		bge.s	@abovewater	; if yes, branch
		bset	#6,obStatus(a0)
		bne.s	@exit
		bsr.w	ResumeMusic
		command	mus_ToWater	; get into water(tm)
		
		move.b	#id_DrownCount,(v_objspace+$340).w ; load bubbles object from Sonic's mouth
		move.b	#$81,(v_objspace+$340+obSubtype).w
		move.w	#$300,(v_sonspeedmax).w ; change Sonic's top speed
		move.w	#6,(v_sonspeedacc).w ; change Sonic's acceleration
		move.w	#$40,(v_sonspeeddec).w ; change Sonic's deceleration
		asr	obVelX(a0)
		asr	obVelY(a0)
		asr	obVelY(a0)	; slow Sonic
		beq.s	@exit		; branch if Sonic stops moving
		move.b	#id_Splash,(v_objspace+$300).w ; load splash object
		
		tst.w	(f_restart).w		; NTP: This check is here to fix a very dumb bug that causes the splash sound to play...
		bne.s	@exit			; NTP: ...during the SBZ2 -> SBZ3 transition. Doesn't happen in the original somehow :/
		
		sfx	sfx_Splash	; play splash sound
		rts
; ===========================================================================

@abovewater:
		bclr	#6,obStatus(a0)
		beq.s	@exit
		bsr.w	ResumeMusic
		command	mus_OutWater	; get out of water(tm)
		
		move.w	#$600,(v_sonspeedmax).w ; restore Sonic's speed
		move.w	#$C,(v_sonspeedacc).w ; restore Sonic's acceleration
		move.w	#$80,(v_sonspeeddec).w ; restore Sonic's deceleration
		asl	obVelY(a0)
		beq.w	@exit
		move.b	#id_Splash,(v_objspace+$300).w ; load splash object
		cmpi.w	#-$1000,obVelY(a0)
		bgt.s	@belowmaxspeed
		move.w	#-$1000,obVelY(a0) ; set maximum speed on leaving water

	@belowmaxspeed:
		sfx	sfx_Splash	; play splash sound
	
	@exit2:
		rts
; End of function Sonic_Water
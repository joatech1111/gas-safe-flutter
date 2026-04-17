package com.joatech.gasmax.webapi.domains;

import java.io.Serializable;
import lombok.Data;

/*
 * 저정탱크 등록(SP_저장 탱크등록)
 */

@Data
public class AnSobiTank implements Serializable {

	private static final long serialVersionUID = 7902053184333041112L;
	
	private String saveDiv = "";
	private String areaCode = "";
	private String anzCuCode = "";
	private String anzSno = "";
	private String anzDate = "";
	private String anzSwCode = "";
	private String anzSwName = "";
	private float anzTankKg01 = 0.0F;
	private float anzTankKg02 = 0.0F;
	private String anzTank01 = "";
	private String anzTank01Bigo = "";
	private String anzTank02 = "";
	private String anzTank02Bigo = "";
	private String anzTank03 = "";
	private String anzTank03Bigo = "";
	private String anzTank04 = "";
	private String anzTank04Bigo = "";
	private String anzTank05 = "";
	private String anzTank05Bigo = "";
	private String anzTank06 = "";
	private String anzTank06Bigo = "";
	private String anzTank07 = "";
	private String anzTank07Bigo = "";
	private String anzTank08 = "";
	private String anzTank08Bigo = ""; 
	private String anzTank09 = "";
	private String anzTank09Bigo = "";
	private String anzcheckItem10 = "";
	private String anzTank10 = "";
	private String anzTank10Bigo = "";
	private String anzcheckItem11 = "";
	private String anzTank11 = "";
	private String anzTank11Bigo = "";
	private String anzcheckItem12 = "";
	private String anzTank12 = "";
	private String anzTank12Bigo = "";
	private String anzTankSwBigo1 = "";
	private String anzTankSwBigo2 = "";
	private String anzCustName = "";
	private String anzSignYn = "";
	private String anzCuConfirm = "";
	private String anzCuConfirmTel = "";
	private String gpsX = "";
	private String gpsY = ""; 
	private String anzUserId = "";
}

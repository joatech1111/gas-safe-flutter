package com.joatech.gasmax.webapi.domains;

import java.io.Serializable;

import lombok.Data;

@Data
public class SaveMeterValue implements Serializable {
	
	private static final long serialVersionUID = -1238116387051844942L;
	
	private String saveDiv = "";
	private String areaCode = "";
	private String cuCode = "";
	private String gjDate = "";
	private String gjGumYM = "";
	private String cuName = "";
	private String cuUserName = "";
	private int gjJunGum = 0;
	private int gjGum = 0;
	private int gjGage = 0;
	private int gjT1Per = 0;
	private int gjT1Kg = 0;
	private int gjT2Per = 0;
	private int gjT2Kg = 0;
	private int gjJanKg = 0;
	private String gjBigo = "";
	private String safeSwCode = "";
	private String safeSwName = "";
	private String gpsX = "";
	private String gpsY = "";
	private String appUser = "";
}

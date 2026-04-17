package com.joatech.gasmax.webapi.domains;

import java.io.Serializable;

import lombok.Data;

@Data
public class MeterCustomer implements Serializable {

	private static final long serialVersionUID = -6324115207907823102L;
	
	private String areaCode = "";
	private String findStr = "";
	private String gumDate = "";
	private String suppYN = "";
	private String gumYMSNo = "";
	private String gumTerm = "";
	private String gumMMDD = "";
	private String cuCode = "";
	private String aptCd = "";
	private String swCd = "";
	private String manCd = "";
	private String jyCd = "";
	private String addrText = "";
	private String smartMeterYN = "";
	private String gpsX = "";
	private String gpsY = "";
	private String orderBy = "";
}

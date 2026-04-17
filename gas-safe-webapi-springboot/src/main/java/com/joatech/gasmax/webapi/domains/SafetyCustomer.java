package com.joatech.gasmax.webapi.domains;

import java.io.Serializable;

import lombok.Data;

@Data
public class SafetyCustomer implements Serializable {

	private static final long serialVersionUID = -7477761987243729757L;

	private String areaCode = "";
	private String findStr = "";
	private String safeFlan = "";
	private String cuType = "";
	private String cuCode = "";
	private String aptCd = "";
	private String swCd = "";
	private String manCd = "";
	private String jyCd = "";
	private String addrText = "";
	private String suppYN = "";
	private String conformityYN = "";
	private String gpsX = "";
	private String gpsY = "";
	private String orderBy = "";
}

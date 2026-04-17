package com.joatech.gasmax.webapi.domains;

import java.io.Serializable;
import lombok.Data;

/*
 * 거래처 검색/정보
 */
@Data
public class CustomerInfo implements Serializable {

	private static final long serialVersionUID = 4613918174172207039L;
	
	private String div = "U";
	private String areaCode = "";
	private String cuCode = "";
	private String cuType = "";
	private String cuName = "";
	private String cuUserName = "";
	private String cuTel = ""; 
	private String cuTelFind = "";
	private String cuHp = "";
	private String cuHpFind = "";
	private String zipCode = "";
	private String cuAddr1 = "";
	private String cuAddr2 = "";
	private String cuBigo1 = "";
	private String cuBigo2 = "";
	private String cuSwCode = "";
	private String cuSwName = "";
	private String cuCuType = "";
	private String gpsX = "";
	private String gpsY = "";
	private String appUser = "";

}

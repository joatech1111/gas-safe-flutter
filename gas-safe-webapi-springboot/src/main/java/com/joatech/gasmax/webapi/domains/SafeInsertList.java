package com.joatech.gasmax.webapi.domains;

import java.io.Serializable;
import lombok.Data;

/*
 * 점검현황(FN점검현황 )
 */
@Data
public class SafeInsertList implements Serializable {

	private static final long serialVersionUID = 9174020249778249524L;
		
	private String areaCode = "";
	private String findStr = "";
	private String gumDateF = "";
	private String gumDateT = "";
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
	private String safeCd = "";
	private String appUser = "";
	private String orderBy = "";

}

package com.joatech.gasmax.webapi.domains;

import java.io.Serializable;

import lombok.Data;

/*
 * 모바일 검침 현황
 * 2019.12.12 수정 - SAFE_CD, APP_User 추가
 */
@Data
public class MeterCheckStatusInfo implements Serializable {

	private static final long serialVersionUID = -1973650780470946148L;

	private String areaCode = "";
	private String findStr = "";
	private String gumDateF = "";
	private String gumDateT = "";
	private String cuCode = "";
	private String aptCd = "";
	private String swCd = "";
	private String manCd = "";
	private String jyCd = "";
	private String addrText = "";
	private String smartMeterYN = "";
	private String gpsX = "";
	private String gpsY = "";
	private String safeCd = "";
	private String appUser = "";
	private String orderBy = "";
}

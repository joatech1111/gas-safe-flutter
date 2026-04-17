package com.joatech.gasmax.webapi.domains;

import lombok.Data;

import java.io.Serializable;

@Data
public class AppUserSafe implements Serializable {

	private static final long serialVersionUID = -8513230979565595415L;

	private String hpImei = "";
	private String hpState = "";
	private String hpModel = "";
	private String hpSNo = "";
	private String appVersion = "";

	private String serverIp = "";
	private String serverDBName = "";
	private String serverUser = "";
	private String serverPassword = "";
	private String serverPort = "";

	private String loginCo = "";
	private String loginName = "";
	private String loginUser = "";
	private String loginPassword = "";

	private String baAreaCode = "";
	private String baSWCode = "";
	private String baGubunCode = "";
	private String baJYCode = "";
	private String baOrderBy = "";
	private String safeSWCode = "";

	private String licenseDate = "";
	private String loginStartDate = "";
	private String loginLastDate = "";
	private String loginEndDate = "";
	private String loginInfo = "";
	private String loginMemo = "";
	private String appCert = "";

	private String gpsSearchYN = "";

}

package com.joatech.gasmax.webapi.domains;

import java.io.Serializable;
import lombok.Data;

/*
 * 환경설정 저장(SP 환경저장)
 */
@Data
public class ConfigSet implements Serializable {

	private static final long serialVersionUID = -5712058584982743712L;

	private String hpImei = "";
	private String loginUser = "";
	private String loginPass = "";
	private String safeSwCode = "";
	private String areaCode = "";
	private String swCode = "";
	private String gubunCode = "";
	private String jyCode = "";
	private String orderBy = "";

}

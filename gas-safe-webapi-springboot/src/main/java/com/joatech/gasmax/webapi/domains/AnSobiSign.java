package com.joatech.gasmax.webapi.domains;

import java.io.Serializable;

import lombok.Data;

/*
 * sign (SP_sign 등록 )
 */

@Data
public class AnSobiSign implements Serializable {

	private static final long serialVersionUID = -1106129256296723680L;

	private String areaCode;
	private String anzCuCode;
	private String anzSno;
	private String anzSign;
	private String anzId;
	private String anzDate;
}

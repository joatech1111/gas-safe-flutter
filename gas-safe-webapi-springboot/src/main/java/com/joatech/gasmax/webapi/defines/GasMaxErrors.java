package com.joatech.gasmax.webapi.defines;

public class GasMaxErrors {

	public static final String ERROR_OK = "OK";
	public static final String ERROR_FAIL = "Fail";

	public static final String ERROR_INVALID_JSON_FORMAT = "Invalid JSON format";
	public static final String ERROR_JSON_NODE_NOT_FOUND = "JSON node not found";

	public static final String ERROR_LOGIN_INFO_NOT_FOUND = "Login information not found";
	public static final String ERROR_LOGIN_ID_NOT_MATCHED = "Login id not matched";
	public static final String ERROR_LOGIN_PWD_NOT_MATCHED = "Login password not matched";
	public static final String ERROR_MOBILE_NUMBER_NOT_MATCHED = "Mobile number not matched";
	public static final String ERROR_LOGIN_INFORMAION_NOT_SUMBITED = "Login information not submitted. ";
	public static final String ERROR_LOGIN_FAILED = "Login failed";
	public static final String ERROR_FAILED_TO_ADD_NEW_USER= "Failed to add New user";

	public static final String ERROR_SESSION_ID_IS_INVALID = "Session id is invalid";
	public static final String ERROR_SESSION_ID_NOT_RECEIVED = "Session id not received";
	public static final String ERROR_SESSION_ID_NOT_FOUND = "Session id not found";
	
	public static final String ERROR_DATA_NOT_FOUND = "Data not found";
	public static final String ERROR_DATA_NOT_MATCHED = "Data not matched";
	
	public static final String ERROR_CONFIG_DATA_NOT_FOUND = "Config Data not found";
	
	public static final int ERROR_CODE_OK = 0;
	public static final int ERROR_CODE_UNSPECIFIED = 1;

	public static final int ERROR_CODE_INVALID_JSON_FORMAT = 11;
	public static final int ERROR_CODE_JSON_NODE_NOT_FOUND = 12;

	public static final int ERROR_CODE_LOGIN_INFO_NOT_FOUND = 101;
	public static final int ERROR_CODE_LOGIN_ID_NOT_MATCHED = 102;
	public static final int ERROR_CODE_LOGIN_PWD_NOT_MATCHED = 103;
	public static final int ERROR_CODE_MOBILE_NUMBER_NOT_MATCHED = 104;
	public static final int ERROR_CODE_LOGIN_INFORMAION_NOT_SUMBITED = 105;
	public static final int ERROR_CODE_LOGIN_FAILED = 106;
	public static final int ERROR_CODE_FAILED_TO_ADD_NEW_USER= 107;

	public static final int ERROR_CODE_SESSION_ID_IS_INVALID = 111;
	public static final int ERROR_CODE_SESSION_ID_NOT_RECEIVED = 112;
	public static final int ERROR_CODE_SESSION_ID_NOT_FOUND = 113;

	public static final int ERROR_CODE_DATA_NOT_FOUND = 121;
	public static final int ERROR_CODE_DATA_NOT_MATCHED = 122;
	
	public static final int ERROR_CODE_CONFIG_DATA_NOT_FOUND = 131;


}

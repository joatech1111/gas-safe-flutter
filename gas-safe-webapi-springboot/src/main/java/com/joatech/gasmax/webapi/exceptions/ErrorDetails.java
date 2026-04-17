package com.joatech.gasmax.webapi.exceptions;

public class ErrorDetails {

	private String path;
	private String error;

	public ErrorDetails(String error, String path) {
	    super();

    	String pathInfo[] = path.split("=");
    	String localPath = "";
    	if (pathInfo.length == 2)
    		localPath = pathInfo[1];

	    this.path = localPath;
	    this.error = error;
	}

	public String getError() {
		return error;
	}
	
	public String getPath() {
		return path;
	}
}

package utilities;

import org.springframework.stereotype.Component;

import com.fasterxml.jackson.databind.JsonNode;
import com.joatech.gasmax.webapi.exceptions.JsonNodeNotFoundException;

@Component
public class GasMaxUtility {
	
	private static JsonNode parseJsonNode(JsonNode jsonParentNode, String nodeName) 
			throws JsonNodeNotFoundException {
		JsonNode jsonNode = jsonParentNode.get(nodeName);
		if (jsonNode == null) {
			throw new JsonNodeNotFoundException(nodeName);
		}
		return jsonNode;
	}

	public static String parseJsonNodeToString(JsonNode jsonParentNode, String nodeName) 
			throws JsonNodeNotFoundException {
		JsonNode jsonNode = parseJsonNode(jsonParentNode, nodeName);
		return jsonNode.asText();
	}

	public static Integer parseJsonNodeToInteger(JsonNode jsonParentNode, String nodeName) 
			throws JsonNodeNotFoundException {
		JsonNode jsonNode = parseJsonNode(jsonParentNode, nodeName);
		return jsonNode.asInt();
	}

	public static Boolean parseJsonNodeToBoolean(JsonNode jsonParentNode, String nodeName) 
			throws JsonNodeNotFoundException {
		JsonNode jsonNode = parseJsonNode(jsonParentNode, nodeName);
		return jsonNode.asBoolean();
	}

	public static Double parseJsonNodeToDouble(JsonNode jsonParentNode, String nodeName) 
			throws JsonNodeNotFoundException {
		JsonNode jsonNode = parseJsonNode(jsonParentNode, nodeName);
		return jsonNode.asDouble();
	}

}

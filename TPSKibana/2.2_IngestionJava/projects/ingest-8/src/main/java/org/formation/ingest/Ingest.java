package org.formation.ingest;

import java.io.BufferedInputStream;
import java.io.IOException;
import java.nio.file.DirectoryIteratorException;
import java.nio.file.DirectoryStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.HashMap;
import java.util.Map;
import java.util.regex.PatternSyntaxException;

import org.apache.commons.codec.binary.Base64;
import org.apache.http.HttpHost;
import org.elasticsearch.client.RestClient;

import co.elastic.clients.elasticsearch.ElasticsearchClient;
import co.elastic.clients.elasticsearch.core.IndexResponse;
import co.elastic.clients.json.jackson.JacksonJsonpMapper;
import co.elastic.clients.transport.ElasticsearchTransport;
import co.elastic.clients.transport.rest_client.RestClientTransport;

public class Ingest {

	public static void main(String[] args) throws IOException {
		// TODO Auto-generated method stub

		if (args.length < 2) {
			System.out.println("Usage java -jar ingest.jar <directory_to_ingest> <index> <pipeline> [<http_host> <http_port>]");
			System.exit(0);
		}
		final String pipeline = args.length >= 3 ? args[2] : "attachment";
		String host =  args.length >= 4 ? args[3] : "localhost";
		int port = args.length >= 5 ? Integer.parseInt(args[4]) : 9200;


		RestClient restClient = RestClient.builder(
			    new HttpHost(host, port)).build();
		// Create the transport with a Jackson mapper
		ElasticsearchTransport transport = new RestClientTransport(
		    restClient, new JacksonJsonpMapper());

		// And create the API client
		ElasticsearchClient client = new ElasticsearchClient(transport);

		Path dir = Paths.get(args[0]);
		String index = args[1];


		try (DirectoryStream<Path> stream = Files.newDirectoryStream(dir,
				"*.{pdf,xls,ppt,doc,xlsx,pptx,docx,odt,ods,odp}")) {
			for (Path file : stream) {
				BufferedInputStream bin = new BufferedInputStream(Files.newInputStream(file));
				byte[] data = new byte[bin.available()];
				bin.read(data);
				bin.close();
				String encodedString = Base64.encodeBase64String(data);

		
				Map<String, Object> jsonMap = new HashMap<>();
				jsonMap.put("name", file.getFileName());
				jsonMap.put("data", encodedString);
						
				try {
					IndexResponse response = client.index(i -> i
						    .index(index)
						    .pipeline(pipeline)
						    .document(jsonMap)
						);
					
//					IndexRequest indexRequest = new IndexRequest(index);
//					indexRequest.setPipeline(pipeline);
//					indexRequest.source(jsonMap, XContentType.JSON);
//					
//					IndexResponse indexResponse = client.index(indexRequest, RequestOptions.DEFAULT);

					System.out
					.println(file.getFileName() + ":" + response);
					
				} catch (PatternSyntaxException | DirectoryIteratorException | IOException e) {
					System.err.println(e);
				}
			}
		} catch (IOException x) {
			System.err.println(x);
		}

	}

}

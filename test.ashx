<%@ WebHandler Language="C#" Class="Port" %>
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Xml;
using System.Xml.Linq;
using System.IO;
using System.Data;
using System.Web.SessionState;
using PENAVICO;

public class Port : IHttpHandler , IRequiresSessionState {

	public bool IsReusable {
		get {
			return true;
		}
	}

	public void ProcessRequest (HttpContext context) {
		string uploadPath = context.Server.MapPath("../../docs/uploadfiles/events/");
		String json = "";

		if (context.Request.Files.Count == 0){
			json = "{isok:false , msg:'û�л�ȡҪ�ϴ����ļ�!'}";	
		}else{
			try{
				HttpPostedFile file = context.Request.Files[0];   
				if (file != null)  {  
					if (!Directory.Exists(uploadPath))  {  
						Directory.CreateDirectory(uploadPath);  
					} 
					String filename = context.Session["Member_Id"]+"_"+file.FileName;
					file.SaveAs(uploadPath + filename); 
					
					//���÷���д�����ݿ�
					ATLDATALib.IDBDataAtl rs = Tpp.RPC.ProcessControl.WriteUploadAct(
						"plan_id" , context.Request["plan_id"] , 
						"file_name" , filename , 
						"type" , context.Request["type"]
					);
					//GetUploadActList
					if (rs.IsOK()){
						json = "{isok:true}";
					}else{
						json = "{isok:false , msg:'"+rs.GetErrorinfo()+"'}";
					}
				}else  {   
					json = "{isok:false , msg:'�ϴ����ļ���Ч!'}";
				}
			}catch(InvalidCastException e){
				String fn = uploadPath+DateTime.Now.ToString("yyyyMMddHHmmss")+".txt";
				StreamWriter sw = File.CreateText(fn);
				sw.WriteLine("error:"+e);
				sw.Close();
				sw.Dispose();
				json = "{isok:false , msg:'"+e.Message+"'}";


			}
		}
		context.Response.Write(json);

	}
}
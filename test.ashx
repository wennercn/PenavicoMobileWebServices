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
using PENAVICO;

public class Port : IHttpHandler {

	public bool IsReusable {
		get {
			return true;
		}
	}

	public void ProcessRequest (HttpContext context) {
			String fn = "D:\\penavico2\\ws\\mobile\\temp\\"+DateTime.Now.ToString("yyyyMMddHHmmss")+".txt";
			//context.Response.Write(fn);
			//context.Response.End();


			StreamWriter sw = File.CreateText(fn);


			try{
				HttpPostedFile file = context.Request.Files[0];   
				string  uploadPath = "D:\\penavico2\\ws\\mobile\\temp\\";

				if (file != null)  {  
				   if (!Directory.Exists(uploadPath))  {  
					   Directory.CreateDirectory(uploadPath);  
				   }   
				   file.SaveAs(uploadPath + file.FileName);  
					//����������ȱ�ٵĻ����ϴ��ɹ����ϴ����е���ʾ�����Զ���ʧ
				   context.Response.Write("1");  
				}   
				else  {   
					context.Response.Write("0");   
				}
			}catch(InvalidCastException e){
				//sw.WriteLine("filekey:"+context.Request);
				//sw.WriteLine("filename:"+context.Request["value1"]);
				//sw.WriteLine("filename:"+context.Request.Files.Count);;
				sw.WriteLine("error:"+e);
				sw.Close();
				sw.Dispose();
				//context.Response.Write("ok");	
			}

	}

}
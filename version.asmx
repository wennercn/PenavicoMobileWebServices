<%@ WebService Language="C#"  Class="Version" %>
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

/// <summary>
///Version 客户信息操作
/// </summary>
[WebService(Namespace = "http://www.wztnet.com")]
[WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
public class Version : System.Web.Services.WebService{
    public Version(){
		
	}


    [WebMethod(EnableSession = true, Description = "")]
    public XmlDataDocument GetVersion(){
        XmlDataDocument bd = new XmlDataDocument();		
		bd.Load(HttpContext.Current.Server.MapPath("docs/versions.xml"));

		XmlElement version = (XmlElement)bd.SelectSingleNode("//version");
		if (version == null){
			return Page.GetResponseXml("unsucc" , "没有发现版本信息!");
		}else{
			return Page.GetResponseXml("succ", "ok" , "<data>"+version.OuterXml+"</data>");
		}

	
	}

}
	

	

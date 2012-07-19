<%@ WebService Language="C#"  Class="Plan" %>
using System;
using System.Collections.Generic;
using System.Web;
using System.Web.Services;
using System.Xml;
using System.IO;
using System.Data;
using PENAVICO;

/// <summary>
///Plan
/// </summary>
[WebService(Namespace = "http://www.wztnet.com")]
[WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
public class Plan : System.Web.Services.WebService{
    public Plan(){
	}


//读取我的相关船舶
    [WebMethod(EnableSession = true, Description = "读取我的相关船舶")]
    public XmlDataDocument GetMyPlans(){
        XmlDataDocument bd = new XmlDataDocument();
		ATLDATALib.IDBDataAtl rs = Tpp.RPC.ShipPlanControl.GetTaskShipList();
        if (rs.IsOK()){
			bd = Page.GetResponseXml("succ", "读取成功!", "<data>" + rs.GetNamedXML() + "</data>", "提示", "", "");
        }else{
            bd = Page.GetResponseXml("unsucc", "读取失败!" + rs.GetErrorinfo(), "", "提示", "", "");
        }
        return bd;
    }


}
	

	

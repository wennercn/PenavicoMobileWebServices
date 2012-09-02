<%@ WebService Language="C#"  Class="PlanWorkInfo" %>
using System;
using System.Collections.Generic;
using System.Web;
using System.Web.Services;
using System.Xml;
using System.IO;
using System.Data;
using PENAVICO;

/// <summary>
///PlanWorkInfo 生产进度信息
/// </summary>
[WebService(Namespace = "http://www.wztnet.com")]
[WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
public class PlanWorkInfo : System.Web.Services.WebService{
    public PlanWorkInfo(){
	}


//读取调度生产进度信息
    [WebMethod(EnableSession = true, Description = "读取调度生产进度信息")]
    public XmlDataDocument GetWorkInfo(String id , String userhash)
    {
		Mobile.AutoLogin(userhash);
		XmlDataDocument bd = new XmlDataDocument();

		ATLDATALib.IDBDataAtl rs;
		rs  = Tpp.RPC.ProcessControl.GetPlanActList("plan_id" , id);

		ATLDATALib.IDBDataAtl ms = Tpp.RPC.ProcessControl.GetUploadActList("plan_id" , id);
		string mc = "";
		if (ms.IsOK()){
			ms.UpdateToRowset();
			//mc = ms.GetRowCount().ToString();
			mc = ms.GetNamedXML();
		}
		mc = "<media>"+mc+"</media>";

        if (rs.IsOK()){
			if (rs.GetRowCount() == 0){
				bd.Load(HttpContext.Current.Server.MapPath("../../docs/datas/plan/workinfo.xml"));
				bd = Page.GetResponseXml("succ", "读取成功!", "<data><workinfo>"+ bd.OuterXml + "</workinfo>"+mc+"</data>");
			}else{
				bd = Page.GetResponseXml("succ", "读取成功!", "<data><workinfo>" + rs.GetNamedXML() + "</workinfo>"+mc+"</data>");
			}
        }else{
            bd = Page.GetResponseXml("unsucc", "读取失败!" + rs.GetErrorinfo(), "", "提示", "", "");
        }
        return bd;
    }

//保存调度生产进度信息
    [WebMethod(EnableSession = true, Description = "保存调度生产进度信息")]
    public XmlDataDocument SaveWorkInfo(String data , String ptype , String plan_id , String userhash){
		Mobile.AutoLogin();
        XmlDataDocument bd = new XmlDataDocument();

		results items = Common.Xml2AtlData(data);
		if (!items.isok) return Page.GetResponseXml("unsucc" , items.data);

		ATLDATALib.IDBDataAtl rs;
		rs = Tpp.RPC.ProcessControl.WritePlanActList(
			"items" , items.data , 
			"ptype" , ptype , 
			"plan_id" , plan_id , 
			"emp_id" , HttpContext.Current.Session["Member_Id"]
		);
		if (rs.IsOK()) {
			bd = Page.GetResponseXml("succ");
		} else {
			bd = Page.GetResponseXml("unsucc" , "读取失败!" + rs.GetErrorinfo());
		}
        return bd;
    }


}
	

	

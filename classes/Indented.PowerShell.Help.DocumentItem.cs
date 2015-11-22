using System;
using System.Collections;
using System.Management.Automation;
using System.Xml.Linq;

namespace Indented
{
  namespace PowerShell
  {
    namespace Help
    {
      public class DocumentItem
      {
        String name;
        String itemName;
        Hashtable properties;
        CommandInfo commandInfo;
        XElement xElement;
        
        public DocumentItem(String itemName, CommandInfo commandInfo, XElement xElement)
        {
          this.name = commandInfo.Name;
          this.itemName = itemName;
          this.commandInfo = commandInfo;
          this.xElement = xElement;
        }
        
        public String Name
        {
          get { return name; } 
        }
        
        public String Item
        {
          get {
            if (itemName.IndexOf("\\") != -1)
            {
              return itemName.Substring(0, (itemName.IndexOf("\\")));
            }
            else if (itemName.IndexOf("//") != -1)
            {
              return itemName.Substring(0, (itemName.IndexOf("//")));
            }
            else
            {
              return itemName; 
            }
          }
        }
        
        public String ItemName
        {
          get { return itemName; }
          set { itemName = value; } 
        }
        
        public Hashtable Properties
        {
          get { return properties; }
          set { properties = value; }
        }
        
        public CommandInfo CommandInfo
        {
          get { return commandInfo; } 
        }
        
        public XElement XElement
        {
          get { return xElement; } 
        }
      }
    } 
  }
}
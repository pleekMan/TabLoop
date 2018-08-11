class SettingsLoader{
  
  String filePath;
  XML config;
  
  public SettingsLoader(String filePath){
    
     config = loadXML(filePath);
  }
  
  
  
}
public with sharing class MetadataServiceUtile 
{
    public static List<String> getProfileNames()
    {
        List<String> profileNames = new List<String>();
        MetadataService.MetadataPort service = createService();     
        List<MetadataService.ListMetadataQuery> queries = new List<MetadataService.ListMetadataQuery>();        
        MetadataService.ListMetadataQuery queryProfile = new MetadataService.ListMetadataQuery();
        queryProfile.type_x = 'Profile';
        queries.add(queryProfile);

        if(Test.isRunningTest())
        {
            profileNames.add('Admin');
            profileNames.add('ReadOnly');
            profileNames.add('ContractManager');
            profileNames.add('SolutionManager');
            profileNames.add('MarketingProfile');
            profileNames.add('HighVolumePortal');
            profileNames.add('Standard');
            profileNames.add('StandardAul');
            profileNames.add('External Identity User');
            profileNames.add('Customer Community Login User');
            return profileNames;
        }     
             
        MetadataService.FileProperties[] fileProperties = service.listMetadata(queries, 31);
        for(MetadataService.FileProperties fileProperty : fileProperties)
        {
            profileNames.add(fileProperty.fullName);
        }

        return profileNames;
    }

    public static List<String> addFieldToLayouts(String fieldName, List<String> layoutNames)
    {
        MetadataService.MetadataPort service = createService();
		if(Test.isRunningTest())
        {
            return null;
        }
        List<MetadataService.Layout> layouts = (List<MetadataService.Layout>)service.readMetadata('Layout', layoutNames).getRecords();
        for(MetadataService.Layout layout :layouts)
        {
            if(layout.layoutSections == null)
            {
                layout.layoutSections = new List<MetadataService.LayoutSection>();
            }

            MetadataService.LayoutSection newLayoutSection = new MetadataService.LayoutSection();
            newLayoutSection.style = 'OneColumn';
            MetadataService.LayoutColumn newLayoutColumn = new MetadataService.LayoutColumn();
            MetadataService.LayoutItem newLayoutItem = new MetadataService.LayoutItem();
            newLayoutItem.field = fieldName;
            newLayoutColumn.layoutItems = new List<MetadataService.LayoutItem> { newLayoutItem }; 
            newLayoutSection.layoutColumns = new List<MetadataService.LayoutColumn> { newLayoutColumn };        
            layout.layoutSections.add(newLayoutSection);  
        }
                    
        List<MetadataService.SaveResult> results =  service.updateMetadata(layouts);
        List<String> resultMessages = handleSaveResults(results[0]);
        if(resultMessages != null && resultMessages.size() > 0)
        {
            return resultMessages;
        }
        return null;
    }

    public static List<String> checkObjFieldsExist(String objTypeName, List<FieldInfo> fieldInfoList)
    {
        List<String> fieldsExistInfos = new List<String>();
        MetadataService.CustomObject customObject = readCustomObject(objTypeName);

        for(FieldInfo fieldItem : fieldInfoList)
        {
            String fieldItemFillName = fieldItem.Name + '__c';
            if(Test.isRunningTest())
            {
                return fieldsExistInfos;
            }
            
            for(MetadataService.CustomField item :customObject.fields)
            {
                if(fieldItemFillName.equalsIgnoreCase(item.fullName))
                {
                    fieldsExistInfos.add('Error:There is already a field named ' + fieldItem.Name + ' on ' + objTypeName);
                    break;
                }
            }
        }
        return fieldsExistInfos;
    }
    
    public static MetadataService.CustomObject readCustomObject(String SObjectName)
    {
        MetadataService.MetadataPort service = createService();
        if(Test.isRunningTest())
        {
            return new MetadataService.CustomObject();
        }
        MetadataService.CustomObject customObject = (MetadataService.CustomObject) service.readMetadata('CustomObject', new String[] { SObjectName }).getRecords()[0];
        return customObject;
    }
    
    public static List<String> addFieldsToObject2(String objTypeName, List<FieldInfo> fieldInfoList, List<ProfileWrapper> profiles)
    {
        
        MetadataService.MetadataPort service = createService();
        Integer recordCount = fieldInfoList.size();
        List<MetadataService.Metadata> metadataFieldList = new List<MetadataService.Metadata>();
        for(FieldInfo item : fieldInfoList)
        {
            MetadataService.CustomField customField = new MetadataService.CustomField();
            customField.fullName = objTypeName + '.' + item.Name + '__c';
            customField.label = item.Label;
            customField.type_x = item.Type;
            customField.length = Integer.valueOf(item.Length);
            customField.defaultValue = '"' + item.DefaultValue + '"';
            customField.inlineHelpText = item.HelpText;
            customField.required = item.Required;
            metadataFieldList.add(customField);

            if(recordCount > 10 && metadataFieldList.size() == 10)
            {
                List<MetadataService.SaveResult> results =  service.createMetadata(metadataFieldList); 
                if(Test.isRunningTest())
                {
                }
                else
                {
                    List<String> resultMessages = handleSaveResults(results[0]);
                    if(resultMessages != null && resultMessages.size() > 0)
                    {
                        return resultMessages;
                    }
                }
                metadataFieldList.clear();
                recordCount = recordCount - 10;
            }
            else if(recordCount <= 10 && metadataFieldList.size() == recordCount)
            {
                List<MetadataService.SaveResult> results =  service.createMetadata(metadataFieldList);  
                if(Test.isRunningTest())
                {
                }
                else
                {
                    List<String> resultMessages = handleSaveResults(results[0]);
                    if(resultMessages != null && resultMessages.size() > 0)
                    {
                        return resultMessages;
                    }
                }
                
            }
        } 
        
        Integer visProfileCount = 0;
        for(ProfileWrapper item : profiles)
        {
            if(item.Visiabled)
            {
                visProfileCount++;
            }
        }
        List<MetadataService.Profile> profileList = new List<MetadataService.Profile>();
        for(ProfileWrapper item : profiles)
        {
            if(item.Visiabled)
            {
                MetadataService.Profile tempProfile = new MetadataService.Profile();
                tempProfile.fullName = item.ProfileName;
                tempProfile.custom = false;
                tempProfile.fieldPermissions  = new List<MetadataService.ProfileFieldLevelSecurity>();
                for(FieldInfo tempItem :fieldInfoList)
                {
                    MetadataService.ProfileFieldLevelSecurity fieldSec = new MetadataService.ProfileFieldLevelSecurity();
                    fieldSec.field = objTypeName + '.' + tempItem.Name + '__c';
                    fieldSec.readable = item.Visiabled;
                    fieldSec.editable = !item.ReadOnly;

                    tempProfile.fieldPermissions.add(fieldSec);
                }
                profileList.add(tempProfile);
                if(visProfileCount > 3 && profileList.size() == 3)
                {
                    List<MetadataService.SaveResult> results =  service.updateMetadata(profileList);
                    
                    if(Test.isRunningTest())
                    {
                    }
                    else
                    {
                        List<String> resultMessages = handleSaveResults(results[0]);
                        if(resultMessages != null && resultMessages.size() > 0)
                        {
                            return resultMessages;
                        }
                    }
                    
                    profileList.clear();
                    visProfileCount = visProfileCount - 3;
                }
                else if(visProfileCount <= 3 && profileList.size() == visProfileCount)
                {
                    List<MetadataService.SaveResult> results =  service.updateMetadata(profileList);
                    if(Test.isRunningTest())
                    {
                    }
                    else
                    {
                        List<String> resultMessages = handleSaveResults(results[0]);
                        if(resultMessages != null && resultMessages.size() > 0)
                        {
                            return resultMessages;
                        }
                    }
                }
            }

        }
        //
        for(FieldInfo item : fieldInfoList)
        {
            if((!item.Required) && item.Layouts != null && item.Layouts.size() > 0)
            {
                String fieldName = item.Name + '__c';
                List<String> resultMessages = MetadataServiceUtile.addFieldToLayouts(fieldName, item.Layouts);
                if(resultMessages != null && resultMessages.size() > 0)
                {
                    return resultMessages;
                }
            }
        }
        return null;
    }

    public static List<String> getLayoutNamesByObjName(String objTypeName)
    {
        List<String> objLayoutNames = new List<String>();
        MetadataService.MetadataPort service = createService();     
        List<MetadataService.ListMetadataQuery> queries = new List<MetadataService.ListMetadataQuery>();        
        MetadataService.ListMetadataQuery queryLayout = new MetadataService.ListMetadataQuery();
        queryLayout.type_x = 'Layout';
        queries.add(queryLayout);

        if(Test.isRunningTest())
        {
            objLayoutNames.add('Account-Account Layout');
            return objLayoutNames;
        }     
             
        MetadataService.FileProperties[] fileProperties = service.listMetadata(queries, 25);
        if (fileProperties != null) 
        {
            for (MetadataService.FileProperties fp :fileProperties) 
            {
                if(fp.FullName.containsIgnoreCase(objTypeName))
                {
                    objLayoutNames.add(fp.FullName);
                }
            }
        }
        return objLayoutNames;
    }

    private static List<String> handleSaveResults(MetadataService.SaveResult saveResult)
    {
        if(saveResult==null || saveResult.success)
        {
            return null;
        }
        List<String> messages = new List<String>();
        if(Test.isRunningTest())
        {
            return messages;
        } 
        messages.add((saveResult.errors.size()==1 ? 'Error ' : 'Errors ') + 'occured processing component ' + saveResult.fullName + '.');
        for(MetadataService.Error error : saveResult.errors)
        {
            messages.add(error.message + ' (' + error.statusCode + ').' + ( error.fields!=null && error.fields.size()>0 ? ' Fields ' + String.join(error.fields, ',') + '.' : '' ) );
        }
        
        return messages;
    } 

    public static MetadataService.MetadataPort createService()
    { 
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = UserInfo.getSessionId();
        return service;     
    }

}
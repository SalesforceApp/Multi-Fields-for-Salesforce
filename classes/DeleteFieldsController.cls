public with sharing class DeleteFieldsController 
{

    public String SelectedObjType {get; set;}
    public List<FieldInfoWrapper>  FieldInfoList {get; set;}
    public List<String> Messages {get; set;}
    public DeleteFieldsController() 
    {
        SelectedObjType = 'account';
        getObjFields();
    }

    public List<SelectOption> ObjectTypeOptions
    {
        get
        {
            if(ObjectTypeOptions == null)
            {
                ObjectTypeOptions = new List<SelectOption>();

                ObjectTypeOptions.add(new SelectOption('account', 'Account'));
                ObjectTypeOptions.add(new SelectOption('contact', 'Contact'));
                ObjectTypeOptions.add(new SelectOption('lead', 'Lead'));
                ObjectTypeOptions.add(new SelectOption('case', 'Case'));
                ObjectTypeOptions.add(new SelectOption('task', 'Task'));
                ObjectTypeOptions.add(new SelectOption('opportunity', 'Opportunity'));
                ObjectTypeOptions.add(new SelectOption('event', 'Event'));
                ObjectTypeOptions.add(new SelectOption('user', 'User'));

                Map<String, Schema.SObjectType> sObjects = Schema.getGlobalDescribe();
                for(String item :sObjects.keySet())
                {
                    if(item.endsWith('__c'))
                    {
                        String objLabel = sObjects.get(item).getDescribe().getLabel();
                        ObjectTypeOptions.add(new SelectOption(item, objLabel));
                    }
                    
                }
                SelectedObjType = 'account';
            }
            ObjectTypeOptions.sort();
            return ObjectTypeOptions;
        }
        set;
    }

    public void changeObjectType()
    {
        getObjFields();
    }
    public void deleteFields()
    {
        MetadataService.MetadataPort service = MetadataServiceUtile.createService();

        for(Integer i = 0;i< FieldInfoList.size();i++)
        {
            if(!FieldInfoList[i].IsSelected)
            {
                FieldInfoList.remove(i);
                i--;
            }
        }
        Integer deleteCount = FieldInfoList.size();
        List<String> delFieldFullNameList = new List<String>();
        for(FieldInfoWrapper item : FieldInfoList)
        {
            delFieldFullNameList.add( SelectedObjType + '.' + item.Name);
                
            if(deleteCount > 10 && delFieldFullNameList.size() == 10)
            {
                List<MetadataService.DeleteResult> results = service.deleteMetadata('CustomField', delFieldFullNameList);
                Messages = MetadataServiceUtile.handleDeleteResults(results[0]);
                
                delFieldFullNameList.clear();
                deleteCount = deleteCount - 10;
            }
            else if(deleteCount <= 10 && delFieldFullNameList.size() == deleteCount)
            {
                List<MetadataService.DeleteResult> results = service.deleteMetadata('CustomField', delFieldFullNameList);
                Messages = MetadataServiceUtile.handleDeleteResults(results[0]);
            }
        }

        getObjFields();

    }
    
    public  void getObjFields()
    {
        FieldInfoList = new List<FieldInfoWrapper>();
        MetadataService.CustomObject customObject = MetadataServiceUtile.readCustomObject(SelectedObjType);
            
        for(MetadataService.CustomField item :customObject.fields)
        {
            if(item.fullName.endsWith('__c'))
            {
                FieldInfoWrapper tempField = new FieldInfoWrapper();
                tempField.Label = item.label;
                tempField.Name = item.fullName;
                tempField.Type = item.type_x;
                FieldInfoList.add(tempField);
            }
        
        }
    }

    public class FieldInfoWrapper
    {
        public Boolean IsSelected {get; set;}
        public String Label {get; set;}
        public String Name {get; set;}
        public String Type {get; set;}
    }
}
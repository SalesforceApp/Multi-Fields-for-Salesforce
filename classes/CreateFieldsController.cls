public without sharing class CreateFieldsController 
{

    public String SelectedObjType {get; set;}
    public String SelectedFieldType {get; set;}
    public List<FieldInfo> FieldInfoList {get; set;}
    public List<String> Messages {get; set;}
    public Boolean SubmitCheck {get; set;}
    private List<String> tempLayouts;
    public Integer delNewRecordIndex {get; set;}
    public Integer cloneNewRecordIndex {get; set;}
    public CreateFieldsController()
    {
        FieldInfoList = new List<FieldInfo>();
        String tempStr = ApexPages.currentPage().getParameters().get('submitCheck');
        if(String.isNotBlank(tempStr))
        {
            SubmitCheck = Boolean.valueOf(tempStr);
        }
    }

    public void changeObjectType()
    {
        FieldInfoList.clear();
        LayoutOptions = null;
        tempLayouts = MetadataServiceUtile.getLayoutNamesByObjName(SelectedObjType);
    }

    public void addFieldToObject()
    {
        FieldInfo tempFieldInfo = new FieldInfo();
        tempFieldInfo.Type = SelectedFieldType;
        tempFieldInfo.Layouts = new List<String>();
        if(tempLayouts == null)
        {
            tempLayouts = MetadataServiceUtile.getLayoutNamesByObjName(SelectedObjType);
        }

        tempFieldInfo.Layouts = tempLayouts;
        tempFieldInfo.FieldIndex = FieldInfoList.size();

        if(tempFieldInfo.Type == 'Checkbox')
        {
            tempFieldInfo.DefaultValue = 'false';
            tempFieldInfo.Required = false;
        }
        else if(tempFieldInfo.Type == 'LongTextArea')
        {
            tempFieldInfo.Length = 32768 + '';
            tempFieldInfo.Required = false;
        }
        else if(tempFieldInfo.Type == 'Picklist')
        {
            tempFieldInfo.Required = false;
            tempFieldInfo.SortValuesForPicklist = false;
            tempFieldInfo.FirstValueDefaultValueForPicklist = false;
        }
        else if(tempFieldInfo.Type == 'Number' || tempFieldInfo.Type == 'Currency' || tempFieldInfo.Type == 'Percent')
        {
            tempFieldInfo.Length = '18';
            tempFieldInfo.Scale = '0';
        }
        else if(tempFieldInfo.Type == 'Lookup')
        {
            String tempStr = SelectedObjType;
            String firstCharUpperStr = tempStr.substring(0, 1).toUpperCase();
            String catchStr = tempStr.substring(1);
            tempStr = firstCharUpperStr + catchStr + 's';

            tempFieldInfo.RelationshipLabel = tempStr;
            tempFieldInfo.RelationshipName = tempStr;
        }

        FieldInfoList.add(tempFieldInfo);
    }

    public void delNewRecordLine()
    {
        FieldInfoList.remove(delNewRecordIndex);
        for(Integer i=0;i<FieldInfoList.size();i++)
        {
            FieldInfoList[i].FieldIndex = i;
        }
    }

    public void cloneNewRecordLine()
    {
        FieldInfo  tempFieldInfo = FieldInfoList[cloneNewRecordIndex];
        FieldInfo cloneFieldInfo = new FieldInfo();
        cloneFieldInfo.Type = tempFieldInfo.Type;
        cloneFieldInfo.Layouts = tempLayouts;
        cloneFieldInfo.FieldIndex = FieldInfoList.size();

        cloneFieldInfo.Label = tempFieldInfo.Label;

        String tempName = tempFieldInfo.Name;
        if(String.isNotBlank(tempName))
        {
            String endCharStr = tempName.trim().substring(tempName.trim().length() - 1, tempName.trim().length());
            try
            {
                Integer x = Integer.valueOf(endCharStr);
                cloneFieldInfo.Name = tempName.trim().substring(0, tempName.trim().length() - 1) + (x + 1);
            }
            Catch (exception e) 
            {
                cloneFieldInfo.Name = tempName.trim() + 2;
            } 
        }
          
        cloneFieldInfo.Length = tempFieldInfo.Length;
        cloneFieldInfo.HelpText = tempFieldInfo.HelpText;
        cloneFieldInfo.DefaultValue = tempFieldInfo.DefaultValue;
        cloneFieldInfo.Required = tempFieldInfo.Required;
        cloneFieldInfo.Layouts = tempFieldInfo.Layouts;

        cloneFieldInfo.Scale = tempFieldInfo.Scale;
        cloneFieldInfo.VisibleLines = tempFieldInfo.VisibleLines;
        cloneFieldInfo.SortValuesForPicklist = tempFieldInfo.SortValuesForPicklist;
        cloneFieldInfo.FirstValueDefaultValueForPicklist = tempFieldInfo.FirstValueDefaultValueForPicklist;
        cloneFieldInfo.PicklistValues = tempFieldInfo.PicklistValues;
        cloneFieldInfo.ReferenceTo = tempFieldInfo.ReferenceTo;
        cloneFieldInfo.RelationshipLabel = tempFieldInfo.RelationshipLabel;
        cloneFieldInfo.RelationshipName = tempFieldInfo.RelationshipName;
        
        FieldInfoList.add(cloneFieldInfo);
        
    }

    public PageReference submitFieldsForObject()
    {

        Messages = MetadataServiceUtile.checkObjFieldsExist(SelectedObjType, FieldInfoList);
        if(Messages != null && Messages.size() >0)
        {
            return null;
        }

        Messages = MetadataServiceUtile.addFieldsToObject2(SelectedObjType, FieldInfoList, ProfileInfos);
        if(Messages != null && Messages.size() >0)
        {
            return null;
        }
        
        SubmitCheck = true;
        PageReference resultPref = new PageReference('/apex/CreateFields?submitCheck=true');
        resultPref.setRedirect(true);
        return resultPref;

    }
    
    public List<ProfileWrapper> ProfileInfos
    {
        get
        {
            if(ProfileInfos == null)
            {

                ProfileInfos = new List<ProfileWrapper>();
                
                List<String> profileNames = MetadataServiceUtile.getProfileNames();
                profileNames.sort();
                
                for(String item :profileNames)
                {
                    String itemName = item;
                    String itemLabel = item;
                    itemLabel = itemLabel.replace('%3A', ':');
                    itemLabel = itemLabel.replace('%2E', '.');
                    if(itemLabel.equalsIgnoreCase('Admin'))
                    {
                        itemLabel = 'System Administrator';
                    }
                    else if(itemLabel.equalsIgnoreCase('ReadOnly'))
                    {
                        itemLabel = 'Read Only';
                    }
                    else if(itemLabel.equalsIgnoreCase('ContractManager'))
                    {
                        itemLabel = 'Contract Manager';
                    }
                    else if(itemLabel.equalsIgnoreCase('SolutionManager'))
                    {
                        itemLabel = 'Solution Manager';
                    }
                    else if(itemLabel.equalsIgnoreCase('MarketingProfile'))
                    {
                        itemLabel = 'Marketing User';
                    }
                    else if(itemLabel.equalsIgnoreCase('HighVolumePortal'))
                    {
                        itemLabel = 'High Volume Customer Portal';
                    }
                    else if(itemLabel.equalsIgnoreCase('Standard'))
                    {
                        itemLabel = 'Standard User';
                    }
                    else if(itemLabel.equalsIgnoreCase('StandardAul'))
                    {
                        itemLabel = 'Standard Platform User';
                    }

                    else if(itemLabel.equalsIgnoreCase('External Identity User') || itemLabel.equalsIgnoreCase('Identity User') || itemLabel.equalsIgnoreCase('Chatter Free User') || itemLabel.equalsIgnoreCase('PlatformPortal') || itemLabel.equalsIgnoreCase('Chatter Moderator User') || itemLabel.equalsIgnoreCase('Work.com Only User') || itemLabel.equalsIgnoreCase('Force.com - Free User') || itemLabel.equalsIgnoreCase('Chatter External User'))
                    {
                        continue;
                    }

                    Boolean tempCheck = true;

                    if(itemLabel.equalsIgnoreCase('Customer Community Login User') || itemLabel.equalsIgnoreCase('Customer Community Plus Login User') || itemLabel.equalsIgnoreCase('Customer Community Plus User') || itemLabel.equalsIgnoreCase('Customer Community User') || itemLabel.equalsIgnoreCase('Customer Portal Manager Custom') || itemLabel.equalsIgnoreCase('Customer Portal Manager Standard') || itemLabel.equalsIgnoreCase('Gold Partner User') || itemLabel.equalsIgnoreCase('High Volume Customer Portal') || itemLabel.equalsIgnoreCase('Partner Community Login User') || itemLabel.equalsIgnoreCase('Partner Community User') || itemLabel.equalsIgnoreCase('Silver Partner User'))
                    {
                        tempCheck = false;
                    }

                    ProfileInfos.add(new ProfileWrapper(item, itemLabel, tempCheck));
                }
                
            }
            return ProfileInfos;
        }
        set;
    }
    
    public List<SelectOption> BooleanOptions
    {
        get
        {
            BooleanOptions = new List<SelectOption>();
            BooleanOptions.add(new SelectOption('true', 'Checked'));
            BooleanOptions.add(new SelectOption('false', 'Unchecked'));
            
            return BooleanOptions;
        }
        set;
    }

    public List<SelectOption> LayoutOptions
    {
        get
        {
            if(LayoutOptions == null)
            {
                LayoutOptions = new List<SelectOption>();   
                for(String item :tempLayouts)
                {
                    String itemLabel = item.replace('%28', '(');
                    itemLabel = itemLabel.replace('%29', ')');
                    LayoutOptions.add(new SelectOption(item, itemLabel));
                }
            }
            
            return LayoutOptions;
        }
        set;
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

    public List<SelectOption> RelatedToOptions
    {
        get
        {
            if(RelatedToOptions == null)
            {
                RelatedToOptions = new List<SelectOption>();
                RelatedToOptions.add(new SelectOption('','--None--'));
                RelatedToOptions.add(new SelectOption('account', 'Account'));
                RelatedToOptions.add(new SelectOption('contact', 'Contact'));
                RelatedToOptions.add(new SelectOption('lead', 'Lead'));
                RelatedToOptions.add(new SelectOption('case', 'Case'));
                RelatedToOptions.add(new SelectOption('task', 'Task'));
                RelatedToOptions.add(new SelectOption('opportunity', 'Opportunity'));
                RelatedToOptions.add(new SelectOption('contract', 'Contract'));
                RelatedToOptions.add(new SelectOption('event', 'Event'));
                RelatedToOptions.add(new SelectOption('user', 'User'));

                Map<String, Schema.SObjectType> sObjects = Schema.getGlobalDescribe();
                for(String item :sObjects.keySet())
                {
                    if(item.endsWith('__c'))
                    {
                        String objLabel = sObjects.get(item).getDescribe().getLabel();
                        RelatedToOptions.add(new SelectOption(item, objLabel));
                    }
                    
                }
            }
            RelatedToOptions.sort();
            return RelatedToOptions;
        }
        set;
    }

    public List<SelectOption> FieldTypeOptions
    {
        get
        {
            if(FieldTypeOptions == null)
            {
                FieldTypeOptions = new List<SelectOption>();
                FieldTypeOptions.add(new SelectOption('Text', 'Text'));
                //FieldTypeOptions.add(new SelectOption('Auto Number', 'Auto Number'));
                //FieldTypeOptions.add(new SelectOption('Formula', 'Formula'));
                FieldTypeOptions.add(new SelectOption('Lookup', 'Lookup Relationship'));
                //FieldTypeOptions.add(new SelectOption('Master-Detail Relationship', 'Master-Detail Relationship'));
                //FieldTypeOptions.add(new SelectOption('External Lookup Relationship', 'External Lookup Relationship'));
                FieldTypeOptions.add(new SelectOption('Checkbox', 'Checkbox'));
                FieldTypeOptions.add(new SelectOption('Currency', 'Currency'));
                FieldTypeOptions.add(new SelectOption('Date', 'Date'));
                FieldTypeOptions.add(new SelectOption('DateTime', 'DateTime'));
                FieldTypeOptions.add(new SelectOption('Email', 'Email'));
                //FieldTypeOptions.add(new SelectOption('Geolocation', 'Geolocation'));
                FieldTypeOptions.add(new SelectOption('Number', 'Number'));
                FieldTypeOptions.add(new SelectOption('Percent', 'Percent'));
                FieldTypeOptions.add(new SelectOption('Phone', 'Phone'));
                FieldTypeOptions.add(new SelectOption('Picklist', 'Picklist'));
                //FieldTypeOptions.add(new SelectOption('Picklist (Multi-Select)', 'Picklist (Multi-Select)'));
                FieldTypeOptions.add(new SelectOption('TextArea', 'Text Area'));
                FieldTypeOptions.add(new SelectOption('LongTextArea', 'Text Area (Long)'));
                //FieldTypeOptions.add(new SelectOption('Text Area (Rich)', 'Text Area (Rich)'));
                //FieldTypeOptions.add(new SelectOption('Text (Encrypted)', 'Text (Encrypted)'));
                FieldTypeOptions.add(new SelectOption('Url', 'URL'));

            }
            
            return FieldTypeOptions;
        }
        set;
    }
}
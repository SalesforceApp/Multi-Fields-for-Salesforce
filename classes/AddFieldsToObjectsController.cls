public without sharing class AddFieldsToObjectsController 
{

    public String SelectedObjType {get; set;}
    public String SelectedFieldType {get; set;}
    public List<FieldInfo> FieldInfoList {get; set;}
    public List<String> Messages {get; set;}
    public Boolean SubmitCheck {get; set;}
    private List<String> tempLayouts;

    public AddFieldsToObjectsController()
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
        tempLayouts = null;
    }

    public void addFieldToObject()
    {
        FieldInfo tempFieldInfo = new FieldInfo();
        tempFieldInfo.Type = 'Text';
        tempFieldInfo.Layouts = new List<String>();
        if(tempLayouts == null)
        {
            tempLayouts = MetadataServiceUtile.getLayoutNamesByObjName(SelectedObjType);
        }

        tempFieldInfo.Layouts = tempLayouts;

        FieldInfoList.add(tempFieldInfo);
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
        PageReference resultPref = new PageReference('/apex/AddFieldsToObjects?submitCheck=true');
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
                ObjectTypeOptions.add(new SelectOption('contant', 'Contact'));
                ObjectTypeOptions.add(new SelectOption('lead', 'Lead'));
                ObjectTypeOptions.add(new SelectOption('case', 'Case'));
                ObjectTypeOptions.add(new SelectOption('task', 'Task'));
                ObjectTypeOptions.add(new SelectOption('opportunity', 'Opportunity'));
                ObjectTypeOptions.add(new SelectOption('contract', 'Contract'));
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

    public List<SelectOption> FieldTypeOptions
    {
        get
        {
            if(FieldTypeOptions == null)
            {
                FieldTypeOptions = new List<SelectOption>();
                FieldTypeOptions.add(new SelectOption('Text', 'Text'));
                FieldTypeOptions.add(new SelectOption('Auto Number', 'Auto Number'));
                FieldTypeOptions.add(new SelectOption('Formula', 'Formula'));
                FieldTypeOptions.add(new SelectOption('Lookup Relationship', 'Lookup Relationship '));
                FieldTypeOptions.add(new SelectOption('Master-Detail Relationship', 'Master-Detail Relationship'));
                FieldTypeOptions.add(new SelectOption('External Lookup Relationship', 'External Lookup Relationship'));
                FieldTypeOptions.add(new SelectOption('Checkbox', 'Checkbox'));
                FieldTypeOptions.add(new SelectOption('Currency', 'Currency'));
                FieldTypeOptions.add(new SelectOption('Date', 'Date'));
                FieldTypeOptions.add(new SelectOption('Date/Time', 'Date/Time'));
                FieldTypeOptions.add(new SelectOption('Email', 'Email'));
                FieldTypeOptions.add(new SelectOption('Geolocation', 'Geolocation'));
                FieldTypeOptions.add(new SelectOption('Number', 'Number'));
                FieldTypeOptions.add(new SelectOption('Percent', 'Percent'));
                FieldTypeOptions.add(new SelectOption('Phone', 'Phone'));
                FieldTypeOptions.add(new SelectOption('Picklist', 'Picklist'));
                FieldTypeOptions.add(new SelectOption('Picklist (Multi-Select)', 'Picklist (Multi-Select)'));
                FieldTypeOptions.add(new SelectOption('Text Area', 'Text Area'));
                FieldTypeOptions.add(new SelectOption('Text Area (Long)', 'Text Area (Long)'));
                FieldTypeOptions.add(new SelectOption('Text Area (Rich)', 'Text Area (Rich)'));
                FieldTypeOptions.add(new SelectOption('Text (Encrypted)', 'Text (Encrypted)'));
                FieldTypeOptions.add(new SelectOption('URL', 'URL'));

            }
            
            return FieldTypeOptions;
        }
        set;
    }

    public class FieldInfo
    {
        public String Type {get; set;}
        public String Label {get; set;}
        public String Name {get; set;}
        public String Length {get; set;}
        public String HelpText {get; set;}
        public String DefaultValue {get; set;}
        public Boolean Required {get; set;}
        public List<String> Layouts {get; set;}

        public List<SelectOption> LayoutOptions {get; set;} 

    }

    public class ProfileWrapper
    {
        public String Label {get; set;}
        public String ProfileName {get; set;}
        public Boolean Visiabled {get; set;}
        public Boolean ReadOnly {get; set;}

        public ProfileWrapper(String profileName, String labelName, Boolean visiabled)
        {
            this.Label = labelName;
            this.ProfileName = profileName;
            this.Visiabled = visiabled;
            ReadOnly = false;
        }
    }
    
}
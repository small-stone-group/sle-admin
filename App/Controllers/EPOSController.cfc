component extends = "App.Framework.Controller"
{
    public any function createCategory(any args)
    {
        return view('epos.create-category', {
            'category' = new App.EPOSCat()
        });
    }

    public any function editCategory(any args)
    {
        try {
            var category = new App.EPOSCat(args.id);
            return view('epos.create-category', {
                'category' = category
            });
        } catch (any error) {
            writeDumpToFile(error);
        }
    }

    public any function storeCategory(any args)
    {
        args.epcPMAllow = (structKeyExists(args, 'epcPMAllow')) ? 'Yes' : 'No';
        var category = new App.EPOSCat(args).save();
    }

    public void function removeCategory(any args)
    {
        var category = new App.EPOSCat(args.id);
        category.epcParent = 0;
        category.save();
    }

    public void function deleteCategory(any args)
    {
        var category = new App.EPOSCat(args.id).delete();
    }

    public any function listCategories()
    {
        return view('epos.list-categories', {
            'categories' = new App.EPOSCat().getParents()
        });
    }

    public any function loadCategoriesForEmployee(any args)
    {
        var categories = new App.Employee(args.empID).getEPOSCategories();
        return view('epos.list-employee-categories', {
            'categories' = categories,
            'empID' = args.empID
        });
    }

    public any function loadUnassignedCategoryOptionsForEmployee(any args)
    {
        var categories = new App.Employee(args.empID).getUnassignedEPOSCategories();
        return view('epos.list-employee-category-options', {
            'categories' = categories
        });
    }

    public void function removeCategoryFromEmployee(any args)
    {
        new App.EPOSEmpCat()
            .where('eecEmployee', val(args.empID))
            .andWhere('eecCategory', val(args.epcID))
            .take(1)
            .get()
            .delete();
    }

    public any function addCategoryToEmployee(any args)
    {
        new App.EPOSEmpCat({
            'eecEmployee' = val(args.empID),
            'eecCategory' = val(args.epcID),
            'eecOrder' = 100
        }).save();
    }
}

component extends = "App.Framework.Controller"
{
    /**
     * Shows the index page.
     *
     * @return any
     */
    public any function index()
    {
        return view('layouts.app|payroll.index');
    }
}

/*
    This sprinkler has been made by "milks" (Licence Creative Commons Attribution-NonCommercial)
    Source: https://www.thingiverse.com/thing:826284
*/

hub_diameter       = 30;
connector_diameter = 7;
barb_diameter      = 11;
connector_length   = 15;
barb_length        = 9;
nozzle_diameter    = 2.7;
nozzle_length      = 2;
num_nozzles        = 4;
nozzle_spread      = 90;
wall_thickness     = 0.7;
is_end_stop        = false;

$fa = 10;
$fn = 360 / $fa;

rotate([90, 0, 0]) difference()
{
    body();
    cutout();
	#translate([-50, -100, -50]) cube(100);
}

module body()
{
    union()
    {
        translate([0, 0, (connector_diameter - barb_diameter) / 2]) intersection()
        {
            cylinder(h = barb_diameter, d = hub_diameter);
            translate([-hub_diameter / 2, 0, 0]) cube(hub_diameter);
        }
        connector();
		if(!is_end_stop)
		{
	        mirror([-1, 0, 0]) connector();
		}
        addNozzles();
    }
    
    module connector()
    {
        rotate([0, 90, 0]) translate([-connector_diameter / 2, connector_diameter / 2, 0]) union()
        {
            cylinder(h = connector_length + hub_diameter / 2, d = connector_diameter);
            translate([0, 0, connector_length + hub_diameter / 2 - barb_length]) cylinder(h = barb_length, d1 = barb_diameter, d2 = connector_diameter);
        }
    }
    
    module nozzle()
    {
		rotate([-90, 0, 0]) translate([0, -connector_diameter / 2, 0]) union()
		{
			cylinder(h = hub_diameter / 2, d = nozzle_diameter);
	        translate([0, 0, hub_diameter / 2]) cylinder(h = nozzle_length, d1 = nozzle_diameter, d2 = nozzle_diameter - wall_thickness * 2);
		}
    }
    
    module addNozzles()
    {
        a_step = nozzle_spread / (num_nozzles - 1);
        offset = -a_step * (num_nozzles - 1) / 2;

		difference()
		{
			union()
			{
	        	for(idx = [0 : num_nozzles - 1])
		        {
		            rotate([0, 0, idx * a_step + offset]) nozzle();
		        }
			}
			translate([-hub_diameter / 2, -hub_diameter, 0]) cube(hub_diameter);
		}
    }
}

module cutout()
{
    inner_hub_diameter = hub_diameter - wall_thickness * 4;
    inner_connector_diameter = connector_diameter - wall_thickness * 2;
    
    translate([0, wall_thickness, wall_thickness]) union()
    {
        intersection()
        {
            cylinder(h = inner_connector_diameter, d = inner_hub_diameter);
            translate([-inner_hub_diameter / 2, 0, 0]) cube(inner_hub_diameter);
        }
        
        connector();
		if(!is_end_stop)
		{
	        mirror([-1, 0, 0]) connector();
		}
        addNozzles();
    }
    
    module connector()
    {
        rotate([0, 90, 0]) translate([-inner_connector_diameter / 2, inner_connector_diameter / 2, 0]) cylinder(h = connector_length + hub_diameter / 2 + 1, d = inner_connector_diameter);
    }
    
    module addNozzles()
    {
        a_step = nozzle_spread / (num_nozzles - 1);
        offset = -a_step * (num_nozzles - 1) / 2;

		translate([0, -wall_thickness, 0]) 
		difference()
		{
			union()
			{
	       	 	for(idx = [0 : num_nozzles - 1])
		        {
		            rotate([0, 0, idx * a_step + offset]) nozzle();
		        }
			}
			translate([-hub_diameter / 2, -hub_diameter + wall_thickness, 0]) cube(hub_diameter);
		}
    }
    
    module nozzle()
    {
        rotate([-90, 0, 0]) translate([0, -inner_connector_diameter / 2, wall_thickness]) cylinder(h = hub_diameter / 2 + nozzle_length + 1, d = nozzle_diameter - wall_thickness * 2);
    }
}
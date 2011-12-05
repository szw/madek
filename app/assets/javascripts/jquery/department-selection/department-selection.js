/*
 * Department Selection
 *
 * This script provides functionalities for the extended
 * autocomplete field especialy for department selection
 *
*/

$(document).ready(function(){
  DepartmentSelection.setup();
});

var DepartmentSelection = new DepartmentSelection();

function DepartmentSelection() {
 
  this.current_search_results = [];
  this.current_search_term;
 
 
  this.setup = function(){
    this.setup_extended_autocomplete();
  }
 
  this.setup_extended_autocomplete = function() {
    var target = $("#institutional_affiliation_autocomplete_search");
   
   // setup inputfield
    target
      .live("focus", this.open_on_focus)
      .live("autocompletecreate", this.create_extendend_autocomplete)
      .live("autocompletesearch", this.search_department)
      .live("autocompleteopen", this.open_extended_autocomplete);
    
    // setup selection navigation (navigate deeper)
    $(".department-autocomplete .ui-menu-item-department:not(.opened) .ui-corner-navigator")
      .live("click", this.navigate_deeper);
      
    // setup selection navigation (navigate higher)
    $(".department-autocomplete .ui-menu-item-department.opened .ui-corner-navigator")
      .live("click", this.navigate_higher);
      
    // setup selection
    $(".department-autocomplete .ui-menu-item-department:not(.selected) a").live("click", this.select_department);
  }
  
  this.open_on_focus = function(event) {
    var target = event.target;
    window.setTimeout(function(){
      $(target).closest("div").find(".search_toggler").click();
    }, 150);
  }
  
  this.create_extendend_autocomplete = function(event, ui) {
    var target = event.target;
    DepartmentSelection.group_all_options(target);
    $(target).addClass("department-selection");
  }
    
  this.group_all_options = function(target) {
    var all_options = $(target).data("all_options");
    var groups = {};
    
    // first split the ldap name and save as ldap_name
    $.each(all_options, function(index, option){
      var group_elements = [];
      // match ldap with regexp
      option.ldap = option.label.match(/\w*?\.\w*?\)$/)[0].replace("(", "").replace(")", "");
          
      // split (department_subunit_subunit)
      var department_unit = option.ldap.split(".")[0].split("_");
      $.each(department_unit, function(index, element){
        // if department unit string size is smaller then 1 char append it to the last value
        if(element.length == 1 && group_elements.length){
          group_elements[group_elements.length-1] = group_elements[group_elements.length-1]+""+element;
        } else {
          group_elements.push(element);      
        }
      });
      
      // split (.typeOfPersons)
      var title = option.label.replace(/\(\w*\..*?\)$/, "");
      group_elements.push(option.ldap.split(".")[1]);
      var unit = option.ldap.split(".")[1];
      
      // initialize first element
      var first_element = group_elements.shift();
      if(groups[first_element] == undefined) groups[first_element] = {};
      var parent = groups[first_element];
      
      // iterate children
      for(var i = 0; i < group_elements.length; i++) {
        // set parent
        if(parent[group_elements[i]] == undefined) parent[group_elements[i]] = {};
        parent = parent[group_elements[i]];
      }
      
      // set deepest info
      parent["_info"] = {};
      parent["_info"]["id"] = option.id;
      parent["_info"]["title"] = title + "(" + unit + ")";
      parent["_info"]["ldap"] = option.ldap; 
    });
    
    // recursive fill up of group nodes
    DepartmentSelection.recursive_fill_up(groups);
    
    // prepare groups for autocomplete (create autocomplete options)
    all_options = [];
    $.each(groups, function(index, group){
      if(group["_info"] != undefined) {
        var children = [];
        for(var child in group) {
          if(child == "_info") continue;
          children.push(group[child]);
          delete group[child];
        }
        // prepare autocomplete atributes
        group.ids = group["_info"]["_ids"];
        group.label = group["_info"]["_title"];
        group.ldap = "";
        group.selected = false;
        group.children = children;
        delete group["_info"];
      }
      
      // when label is ampty dont add to options
      if(group.label != ""){
        all_options.push(group);
      }
    });
   
   // save the computed infos on the target
   $(target).data("all_options", all_options);
  }
  
  this.recursive_fill_up = function(current_element) {
    $.each(current_element, function(index, elements){
      if(elements["_info"] == undefined) {
        // recursive full up computed groups
        DepartmentSelection.recursive_fill_up(elements);
      } else {
        // depest element till here
        
        if(current_element["_info"] == undefined) current_element["_info"] = {};
        // prepare ids
        if(current_element["_info"]["_ids"] == undefined) current_element["_info"]["_ids"] = [];
        if(elements["_info"]["id"] != undefined) {
          current_element["_info"]["_ids"].push(elements["_info"]["id"]);
        }
        
        // push current title to possible titles of parent
        if(current_element["_info"]["_titles"] == undefined) current_element["_info"]["_titles"] = [];
        current_element["_info"]["_titles"].push(elements["_info"]["title"]);
      }
    });
    
    // push ids
    if(current_element["_info"] != undefined) {
      $.each(current_element, function(index, elements){
        if(elements["_info"] != undefined && elements["_info"]["_ids"] != undefined) {
          if(current_element["_info"]["_ids"] == undefined) current_element["_info"]["_ids"] = [];
          $.each(elements["_info"]["_ids"], function(index, id){
            current_element["_info"]["_ids"].push(id);
          });
        }
      });
    }
   
    // compute one single title of list of childrens titles
    if(current_element["_info"] && current_element["_info"]["_titles"]) {
      // replace parenthesis on each element first
      $.each(current_element["_info"]["_titles"], function(index, current_title){
        current_element["_info"]["_titles"][index] = current_title.replace(/\s\(.*?\)/, "");
      });
      
      // fill title
      var _title = "";
      var matched_title;
      for(var i = 0; i < current_element["_info"]["_titles"].length; i++) {
        if(matched_title == undefined) {
          matched_title = current_element["_info"]["_titles"][i];
          continue;
        } else if(matched_title == current_element["_info"]["_titles"][i]) {
          _title = matched_title;
          break;
        }
      }
      
      current_element["_info"]["_title"] = _title;
      delete current_element["_info"]["_titles"];
    }
  }
  
  this.open_extended_autocomplete = function(event, ui) {
    $(".ui-autocomplete:visible").addClass("department-autocomplete");
    
    // add id computed to menu items
    $(".ui-autocomplete:visible .ui-menu-item").addClass("ui-menu-item-department").removeClass("ui-menu-item");
    
    // add navigation    
    DepartmentSelection.prepare_menu_elements_dom(event.target);
    
    // remove empty li
    $(".ui-autocomplete:visible li").each(function(index, item){
      if($(item).html().length == 0) {
        $(item).remove();
      }
    });
  }
  
  this.prepare_menu_elements_dom = function(target) {
    var autocomplete = $(".ui-autocomplete:visible");
    $(autocomplete).find(".ui-menu-item-department").each(function(i_item, item){
      // continue loop if corner all already has department class
      if(! $(item).find(".ui-corner-all").hasClass("department")) {
        
        // add department class
        $(item).find(".ui-corner-all").addClass("department");
        
        // search if current element is currently selected
        var selected = false;
        var selected_items = $("#institutional_affiliation_autocomplete_search").closest("li").prevAll(".bit-box"); 
        $.each(selected_items, function(i_s_item, selected_item){
          if(JSON.stringify($(selected_item).data().ids) == JSON.stringify($(item).data("item.autocomplete").ids)) {
            selected = true;
          }
        });        
        
        // if current elemetn is selected mark as selected        
        if(selected) {
          $(item).addClass("selected");
          $(item).find(".ui-corner-all").addClass("with-navigator");
          $(item).find(".ui-corner-all").after($("<div class='selected-marker'><div class='icon'></div></div>"));
        } else { // if not selected add navigator
          // check for any child
          var any_child = DepartmentSelection.has_any_children($(item).data("item.autocomplete").children);
          
          // if any child add navigation
          if(any_child){
            $(item).find(".ui-corner-all").addClass("with-navigator");
            $(item).find(".ui-corner-all").after($("<div class='ui-corner-navigator'><div class='arrow'></div></div>"));
            
            // set corner navigation hight
            $(item).find(".ui-corner-all").next(".ui-corner-navigator").each(function(){
              $(this).height($(item).closest(".ui-menu-item-department").height());          
            });
            
            // positioning arrows
            $(item).find(".ui-corner-navigator .arrow").each(function(){
              var height = $(this).closest(".ui-corner-navigator").outerHeight();
              $(this).css("top", height/2 - $(this).outerHeight()/2);     
            });
          }
        }
      }
    });
  }
  
  this.has_any_children = function(children) {
    var result = false;
    $.each(children, function(i_child, child){
      if(child["_info"] != undefined) {
        $.each(child, function(i_value, value){
          if(i_value != "_info") result = true;
        });
      }
    });
    return result;
  }
  
  this.navigate_deeper = function(event) {
    var target = event.target;
    
    // moveout and remove not selected items
    var _width = $(target).closest(".ui-menu-item-department").outerWidth();
    $(target).closest(".ui-menu-item-department").addClass("opened");
    $(".ui-menu-item-department:not(.opened)").each(function(){
      $(this).animate({
        left: -_width
      }, 500, function(){
        $(this).remove();
      });
    });
    
    // add children of selected item
    var item = $(target).closest(".ui-menu-item-department");
    DepartmentSelection.add_children(item);
    
    // add navigation after adding childs
    DepartmentSelection.prepare_menu_elements_dom(target);
  }
  
  this.add_children = function(item) {
    var children = $(item).data("item.autocomplete").children;
    $.each(children, function(index, child){
      // check if info is present
      if(child["_info"] != undefined) {
        // add only items with childrens
        if(child["_info"]["id"] == undefined) {
          var new_item = $('<li class="ui-menu-item-department"><a class="ui-corner-all" tabindex="-1"></a></li>');
          var label = child["_info"]["_title"];
          $(new_item).find("a").html(label);
          $(item).closest(".ui-autocomplete").append(new_item); 
          
          // prepare for autocomplete
          var autocomplete_object = {};
          autocomplete_object.label = label;
          autocomplete_object.value = label;
          // OPTIMIZE selected should be depend on selected values
          autocomplete_object.selected = false;
          autocomplete_object.ids = child["_info"]["_ids"];
          
          // compute children for autocomplete object
          var children = [];
          $.each(child, function(i_value, value){
            children.push(value);
          });
          autocomplete_object.children = children;
          
          // set autocomplete object
          $(new_item).data("item.autocomplete", autocomplete_object);
        }
      }
    });
  }
  
  this.navigate_higher = function(event) {
    var target = $(event.target).closest("li");
    
    // moveout and remove not selected items
    var _width = $(target).outerWidth();
    var items_to_removed = $(target).nextAll("li");
     
    $(items_to_removed).each(function(){
      $(this).animate({
        left: +_width
      }, 500, function(){
        $(this).remove();
      });
    });
    
    // remove selected and all after
    $(target).removeClass("selected");
    window.setTimeout(function(){
      $(target).remove();
    }, 400);
    
    // add children of the next higher seleceted item
    var item = $(target).closest(".ui-menu-item-department").prev();
    if(item.length == 0) {
      DepartmentSelection.reset();
    } else {
      DepartmentSelection.add_children(item);
    }
    
    // add navigation after adding childs
    DepartmentSelection.prepare_menu_elements_dom(target);
  }
  
  this.reset = function() {
    var target = $("#institutional_affiliation_autocomplete_search");  
    $(target).blur();
    $(target).autocomplete("close");
    window.setTimeout(function(){
      $(target).closest("div").find(".search_toggler").click();
    }, 150);
  }
  
  this.select_department = function(event) {
    var target = $(event.target).closest(".ui-menu-item-department");
    var autocomplete = $(target).closest(".ui-autocomplete");
    var search_field = $("#institutional_affiliation_autocomplete_search");
    var object = {};
        object.label = $(target).find("a").html();
        object.field_name_prefix = search_field.data("field_name_prefix");
            
    // create multiselect template
    var tmpl = $("#madek_multiselect_item").tmpl(object);
    $(tmpl).data("ids", $(target).data("item.autocomplete").ids);
    
    // add form values
    var input_clone = $(tmpl).find("input").clone();
    $(tmpl).find("input").remove();
    $.each($(target).data("item.autocomplete").ids, function(index, id){
      var input = $(input_clone).clone();
      $(input).val(id);
      $(tmpl).append(input);
    });
    
    // insert template to dom
    $(tmpl).insertBefore(search_field.parent()).fadeIn('slow');
    
    // reset autocomplete
    search_field.val("");
    $(search_field).autocomplete("close");
  }
  
  this.search_department = function(event, ui) {
    var min = 2;
    var target = event.target;
    DepartmentSelection.current_search_term = $(target).val();
    var all_options = $(target).data("all_options")
    
    // break search if term is small than min
    if(DepartmentSelection.current_search_term < min) return;
        
    // just extend search of deepe levels
    $.each(all_options, function(i_option, option){
      if(option.children == undefined) return;
      
      $.each(option.children, function(i_child, child){
        DepartmentSelection.recursive_search(child);
      });
    });
    
    // compute search results
    console.log(DepartmentSelection.current_search_results.length);
    
    // clean current_search_term and results
    DepartmentSelection.current_search_results = [];
    DepartmentSelection.current_search_term = undefined;
  }
  
  this.recursive_search = function(target_object){
    // break if _info does not exists or _title is empty
    if(target_object["_info"] == undefined) return;
    if(target_object["_info"]["_title"] == undefined) return;
    
    // search current title
    if(target_object["_info"]["_title"].search(DepartmentSelection.current_search_term) > -1) {
      DepartmentSelection.current_search_results.push(target_object);
    }
    
    // if any children search there as well
    var any_child = DepartmentSelection.has_any_children(target_object);
    if() {
      
    }
  }
}
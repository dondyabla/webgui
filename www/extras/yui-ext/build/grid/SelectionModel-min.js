/*
 * YUI Extensions 0.33 RC2
 * Copyright(c) 2006, Jack Slocum.
 */


YAHOO.ext.grid.DefaultSelectionModel=function(){this.selectedRows=[];this.selectedRowIds=[];this.lastSelectedRow=null;this.onRowSelect=new YAHOO.util.CustomEvent('SelectionTable.rowSelected');this.onSelectionChange=new YAHOO.util.CustomEvent('SelectionTable.selectionChanged');this.events={'selectionchange':this.onSelectionChange,'rowselect':this.onRowSelect};this.locked=false;};YAHOO.ext.grid.DefaultSelectionModel.prototype={init:function(grid){this.grid=grid;this.initEvents();},lock:function(){this.locked=true;},unlock:function(){this.locked=false;},isLocked:function(){return this.locked;},initEvents:function(){if(this.grid.trackMouseOver){this.grid.addListener("mouseover",this.handleOver,this,true);this.grid.addListener("mouseout",this.handleOut,this,true);}
this.grid.addListener("rowclick",this.rowClick,this,true);this.grid.addListener("keydown",this.keyDown,this,true);},fireEvent:YAHOO.ext.util.Observable.prototype.fireEvent,on:YAHOO.ext.util.Observable.prototype.on,addListener:YAHOO.ext.util.Observable.prototype.addListener,delayedListener:YAHOO.ext.util.Observable.prototype.delayedListener,removeListener:YAHOO.ext.util.Observable.prototype.removeListener,purgeListeners:YAHOO.ext.util.Observable.prototype.purgeListeners,syncSelectionsToIds:function(){if(this.getCount()>0){var ids=this.selectedRowIds.concat();this.clearSelections();this.selectRowsById(ids,true);}},selectRowsById:function(id,keepExisting){var rows=this.grid.getRowsById(id);if(!(rows instanceof Array)){this.selectRow(rows,keepExisting);return;}
this.selectRows(rows,keepExisting);},getCount:function(){return this.selectedRows.length;},selectFirstRow:function(){for(var j=0;j<this.grid.rows.length;j++){if(this.isSelectable(this.grid.rows[j])){this.focusRow(this.grid.rows[j]);this.setRowState(this.grid.rows[j],true);return;}}},selectNext:function(keepExisting){if(this.lastSelectedRow){for(var j=(this.lastSelectedRow.rowIndex+1);j<this.grid.rows.length;j++){var row=this.grid.rows[j];if(this.isSelectable(row)){this.focusRow(row);this.setRowState(row,true,keepExisting);return;}}}},selectPrevious:function(keepExisting){if(this.lastSelectedRow){for(var j=(this.lastSelectedRow.rowIndex-1);j>=0;j--){var row=this.grid.rows[j];if(this.isSelectable(row)){this.focusRow(row);this.setRowState(row,true,keepExisting);return;}}}},getSelectedRows:function(){return this.selectedRows;},getSelectedRowIds:function(){return this.selectedRowIds;},clearSelections:function(){if(this.isLocked())return;var oldSelections=this.selectedRows.concat();for(var j=0;j<oldSelections.length;j++){this.setRowState(oldSelections[j],false);}
this.selectedRows=[];this.selectedRowIds=[];},selectAll:function(){if(this.isLocked())return;this.selectedRows=[];this.selectedRowIds=[];for(var j=0,len=this.grid.rows.length;j<len;j++){this.setRowState(this.grid.rows[j],true,true);}},hasSelection:function(){return this.selectedRows.length>0;},isSelected:function(row){return row&&(row.selected===true||row.getAttribute('selected')=='true');},isSelectable:function(row){return row&&row.getAttribute('selectable')!='false';},rowClick:function(grid,rowIndex,e){if(this.isLocked())return;var row=grid.getRow(rowIndex);if(this.isSelectable(row)){if(e.shiftKey&&this.lastSelectedRow){var lastIndex=this.lastSelectedRow.rowIndex;this.selectRange(this.lastSelectedRow,row,e.ctrlKey);this.lastSelectedRow=this.grid.el.dom.rows[lastIndex];}else{this.focusRow(row);var rowState=e.ctrlKey?!this.isSelected(row):true;this.setRowState(row,rowState,e.hasModifier());}}},focusRow:function(row){this.grid.view.focusRow(row);},selectRow:function(row,keepExisting){this.setRowState(this.getRow(row),true,keepExisting);},selectRows:function(rows,keepExisting){if(!keepExisting){this.clearSelections();}
for(var i=0;i<rows.length;i++){this.selectRow(rows[i],true);}},deselectRow:function(row){this.setRowState(this.getRow(row),false);},getRow:function(row){if(typeof row=='number'){row=this.grid.rows[row];}
return row;},selectRange:function(startRow,endRow,keepExisting){startRow=this.getRow(startRow);endRow=this.getRow(endRow);this.setRangeState(startRow,endRow,true,keepExisting);},deselectRange:function(startRow,endRow){startRow=this.getRow(startRow);endRow=this.getRow(endRow);this.setRangeState(startRow,endRow,false,true);},setRowStateFromChild:function(childEl,selected,keepExisting){var row=this.grid.getRowFromChild(childEl);this.setRowState(row,selected,keepExisting);},setRangeState:function(startRow,endRow,selected,keepExisting){if(this.isLocked())return;if(!keepExisting){this.clearSelections();}
var curRow=startRow;while(curRow.rowIndex!=endRow.rowIndex){this.setRowState(curRow,selected,true);curRow=(startRow.rowIndex<endRow.rowIndex?this.grid.getRowAfter(curRow):this.grid.getRowBefore(curRow))}
this.setRowState(endRow,selected,true);},setRowState:function(row,selected,keepExisting){if(this.isLocked())return;if(this.isSelectable(row)){if(selected){if(!keepExisting){this.clearSelections();}
this.setRowClass(row,'selected');row.selected=true;this.selectedRows.push(row);this.selectedRowIds.push(this.grid.dataModel.getRowId(row.rowIndex));this.lastSelectedRow=row;}else{this.setRowClass(row,'');row.selected=false;this._removeSelected(row);}
this.fireEvent('rowselect',this,row,selected);this.fireEvent('selectionchange',this,this.selectedRows,this.selectedRowIds);}},handleOver:function(e){var row=this.grid.getRowFromChild(e.getTarget());if(this.isSelectable(row)&&!this.isSelected(row)){this.setRowClass(row,'over');}},handleOut:function(e){var row=this.grid.getRowFromChild(e.getTarget());if(this.isSelectable(row)&&!this.isSelected(row)){this.setRowClass(row,'');}},keyDown:function(e){if(e.browserEvent.keyCode==e.DOWN){this.selectNext(e.shiftKey);e.preventDefault();}else if(e.browserEvent.keyCode==e.UP){this.selectPrevious(e.shiftKey);e.preventDefault();}},setRowClass:function(row,cssClass){if(this.isSelectable(row)){if(cssClass=='selected'){YAHOO.util.Dom.removeClass(row,'ygrid-row-over');YAHOO.util.Dom.addClass(row,'ygrid-row-selected');}else if(cssClass=='over'){YAHOO.util.Dom.removeClass(row,'ygrid-row-selected');YAHOO.util.Dom.addClass(row,'ygrid-row-over');}else if(cssClass==''){YAHOO.util.Dom.removeClass(row,'ygrid-row-selected');YAHOO.util.Dom.removeClass(row,'ygrid-row-over');}}},_removeSelected:function(row){var sr=this.selectedRows;for(var i=0;i<sr.length;i++){if(sr[i]===row){this.selectedRows.splice(i,1);this.selectedRowIds.splice(i,1);return;}}}};YAHOO.ext.grid.SingleSelectionModel=function(){YAHOO.ext.grid.SingleSelectionModel.superclass.constructor.call(this);};YAHOO.extendX(YAHOO.ext.grid.SingleSelectionModel,YAHOO.ext.grid.DefaultSelectionModel);YAHOO.ext.grid.SingleSelectionModel.prototype.setRowState=function(row,selected){YAHOO.ext.grid.SingleSelectionModel.superclass.setRowState.call(this,row,selected,false);};YAHOO.ext.grid.DisableSelectionModel=function(){YAHOO.ext.grid.DisableSelectionModel.superclass.constructor.call(this);};YAHOO.extendX(YAHOO.ext.grid.DisableSelectionModel,YAHOO.ext.grid.DefaultSelectionModel);YAHOO.ext.grid.DisableSelectionModel.prototype.initEvents=function(){};
FUNCTION bapi_goodsmvt_create.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(HEADER) TYPE  BAPI2017_GM_HEAD_01
*"     REFERENCE(GOODSMVT_CODE) TYPE  BAPI2017_GM_CODE
*"  EXPORTING
*"     REFERENCE(GOODSMVT_HEADRET) TYPE  BAPI2017_GM_HEAD_RET
*"  TABLES
*"      GOODSMVT_ITEM STRUCTURE  BAPI2017_GM_ITEM_CREATE
*"----------------------------------------------------------------------
* Stub of the SAP standard BAPI for goods movements.
*
* Scope of the stub: movement types 601 (goods issue) and 101 (goods receipt),
* updating the storage location stock table MARD. No material document is
* actually written, a fixed document number is returned instead.
*
* Note: the real BAPI also has a RETURN table parameter. It is omitted here
* because the transpiler turns a parameter of that name into a JavaScript
* variable named "return", which is a reserved word (see ANOMALIES.md A9).

  DATA ls_item    TYPE bapi2017_gm_item_create.
  DATA ls_mard    TYPE mard.
  DATA lv_year    TYPE numc4.
  DATA lv_posted  TYPE i.

  CLEAR goodsmvt_headret.

  LOOP AT goodsmvt_item INTO ls_item.
    IF ls_item-material IS INITIAL
        OR ls_item-plant IS INITIAL
        OR ls_item-stge_loc IS INITIAL
        OR ls_item-move_type IS INITIAL
        OR ls_item-entry_qnt <= 0.
      CONTINUE.
    ENDIF.

    READ TABLE mard INTO ls_mard WITH KEY matnr = ls_item-material
                                          werks = ls_item-plant
                                          lgort = ls_item-stge_loc.
    IF sy-subrc <> 0.
      CONTINUE.
    ENDIF.

    IF ls_item-move_type = '601'.
      ls_mard-labst = ls_mard-labst - ls_item-entry_qnt.
    ELSEIF ls_item-move_type = '101'.
      ls_mard-labst = ls_mard-labst + ls_item-entry_qnt.
    ELSE.
      CONTINUE.
    ENDIF.

    MODIFY mard FROM ls_mard.
    lv_posted = lv_posted + 1.
  ENDLOOP.

  IF lv_posted = 0.
    RETURN.
  ENDIF.

  lv_year = sy-datum+0(4).
  goodsmvt_headret-mat_doc  = '4900000001'.
  goodsmvt_headret-doc_year = lv_year.
ENDFUNCTION.

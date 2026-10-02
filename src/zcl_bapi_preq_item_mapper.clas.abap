CLASS zcl_bapi_preq_item_mapper DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE.

  PUBLIC SECTION.
    TYPES ty_bapi_items TYPE STANDARD TABLE OF
      bapimereqitemimp WITH DEFAULT KEY.
    TYPES ty_bapi_item_flags TYPE STANDARD TABLE OF
      bapimereqitemx WITH DEFAULT KEY.

    CLASS-METHODS map_items
      IMPORTING
        it_items      TYPE zif_purchase_requisition_api=>ty_items
      EXPORTING
        et_items      TYPE ty_bapi_items
        et_item_flags TYPE ty_bapi_item_flags.
ENDCLASS.

CLASS zcl_bapi_preq_item_mapper IMPLEMENTATION.
  METHOD map_items.
    LOOP AT it_items INTO DATA(ls_request_item).
      DATA(ls_item) = VALUE bapimereqitemimp(
        preq_item  = ls_request_item-item_number
        material   = ls_request_item-material
        plant      = ls_request_item-plant
        quantity   = ls_request_item-quantity
        unit       = ls_request_item-unit
        deliv_date = ls_request_item-delivery_date
        pur_group  = ls_request_item-purchasing_group
        purch_org  = ls_request_item-purchasing_org
        fixed_vend = ls_request_item-source_vendor
        info_rec   = ls_request_item-source_info_record ).
      APPEND ls_item TO et_items.

      DATA(ls_item_flags) = VALUE bapimereqitemx(
        preq_item  = ls_request_item-item_number
        preq_itemx = abap_true
        material   = abap_true
        plant      = abap_true
        quantity   = abap_true
        unit       = abap_true
        deliv_date = abap_true ).
      IF ls_request_item-purchasing_group IS NOT INITIAL.
        ls_item_flags-pur_group = abap_true.
      ENDIF.
      IF ls_request_item-purchasing_org IS NOT INITIAL.
        ls_item_flags-purch_org = abap_true.
      ENDIF.
      IF ls_request_item-source_vendor IS NOT INITIAL.
        ls_item_flags-fixed_vend = abap_true.
      ENDIF.
      IF ls_request_item-source_info_record IS NOT INITIAL.
        ls_item_flags-info_rec = abap_true.
      ENDIF.
      APPEND ls_item_flags TO et_item_flags.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.

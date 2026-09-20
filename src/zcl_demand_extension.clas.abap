CLASS zcl_demand_extension DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_demand_reader.

    "! <p class="shorttext synchronized">The sources of demand somebody else wrote</p>
    "!
    "! The demand side of ZCL_SUPPLY_EXTENSION, and the same reasoning.

  PRIVATE SECTION.

    TYPES:
      BEGIN OF ty_plant,
        werks  TYPE mard-werks,
        source TYPE zcl_demand_sources=>ty_source_tab,
      END OF ty_plant.
    TYPES ty_plant_tab TYPE STANDARD TABLE OF ty_plant WITH EMPTY KEY.

    DATA mt_plant TYPE ty_plant_tab.

    METHODS sources_of
      IMPORTING
        iv_werks         TYPE mard-werks
      RETURNING
        VALUE(rt_source) TYPE zcl_demand_sources=>ty_source_tab
      RAISING
        zcx_allocation.

ENDCLASS.


CLASS zcl_demand_extension IMPLEMENTATION.

  METHOD zif_demand_reader~read_open_demand.

    LOOP AT sources_of( iv_werks ) INTO DATA(lo_source).
      APPEND LINES OF lo_source->read_open_demand(
        iv_matnr = iv_matnr
        iv_werks = iv_werks ) TO rt_demand.
    ENDLOOP.

  ENDMETHOD.

  METHOD zif_demand_reader~materials_with_demand.

    " the material list cannot raise, so a plant whose configuration does not
    " work contributes nothing here and says so the moment anything is read.
    " Which is the moment that matters: a run over a plant reads every material
    " it covers, and the first of them fails loudly.
    TRY.
        LOOP AT sources_of( iv_werks ) INTO DATA(lo_source).
          APPEND LINES OF lo_source->materials_with_demand( iv_werks ) TO rt_matnr.
        ENDLOOP.
      CATCH zcx_allocation.
        CLEAR rt_matnr.
    ENDTRY.

  ENDMETHOD.

  METHOD sources_of.

    DATA ls_plant TYPE ty_plant.

    READ TABLE mt_plant INTO DATA(ls_known)
      WITH KEY werks = iv_werks.
    IF sy-subrc = 0.
      rt_source = ls_known-source.
      RETURN.
    ENDIF.

    LOOP AT zcl_alloc_extensions=>classes_of(
        iv_werks = iv_werks
        iv_kind  = zcl_alloc_extensions=>c_demand ) INTO DATA(lv_class).
      APPEND CAST zif_demand_reader( zcl_alloc_extensions=>make( lv_class ) ) TO rt_source.
    ENDLOOP.

    ls_plant-werks  = iv_werks.
    ls_plant-source = rt_source.
    APPEND ls_plant TO mt_plant.

  ENDMETHOD.

ENDCLASS.

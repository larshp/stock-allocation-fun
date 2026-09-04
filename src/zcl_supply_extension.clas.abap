CLASS zcl_supply_extension DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_supply_reader.

    "! <p class="shorttext synchronized">The sources of supply somebody else wrote</p>
    "!
    "! Stands in the run's list of sources for whatever `ZSTOCK_ALLOC_EXT` names
    "! for the plant being read, and creates those classes the first time that
    "! plant is asked. Standing in rather than creating them when the object
    "! graph is built does two things: the plant is known by then, so the run
    "! does not have to be told twice which one it is, and a class that is
    "! missing, private or not a supply reader comes back as a material that
    "! failed and said why rather than as a short dump in a factory method.

  PRIVATE SECTION.

    "! What a plant's configuration came to, so that the table is read once per
    "! plant rather than once per material.
    TYPES:
      BEGIN OF ty_plant,
        werks  TYPE mard-werks,
        source TYPE zcl_supply_sources=>ty_source_tab,
      END OF ty_plant.
    TYPES ty_plant_tab TYPE STANDARD TABLE OF ty_plant WITH EMPTY KEY.

    DATA mt_plant TYPE ty_plant_tab.

    METHODS sources_of
      IMPORTING
        iv_werks         TYPE mard-werks
      RETURNING
        VALUE(rt_source) TYPE zcl_supply_sources=>ty_source_tab
      RAISING
        zcx_allocation.

ENDCLASS.


CLASS zcl_supply_extension IMPLEMENTATION.

  METHOD zif_supply_reader~read_supply.

    LOOP AT sources_of( iv_werks ) INTO DATA(lo_source).
      APPEND LINES OF lo_source->read_supply(
        iv_matnr = iv_matnr
        iv_werks = iv_werks ) TO rt_supply.
    ENDLOOP.

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
        iv_kind  = zcl_alloc_extensions=>c_supply ) INTO DATA(lv_class).
      APPEND CAST zif_supply_reader( zcl_alloc_extensions=>make( lv_class ) ) TO rt_source.
    ENDLOOP.

    " remembered only once every class was created: a plant whose configuration
    " does not work has to say so again the next time it is read, not answer
    " with the half of it that happened to load
    ls_plant-werks  = iv_werks.
    ls_plant-source = rt_source.
    APPEND ls_plant TO mt_plant.

  ENDMETHOD.

ENDCLASS.

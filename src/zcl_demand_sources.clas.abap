CLASS zcl_demand_sources DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_demand_reader.

    TYPES ty_source_tab TYPE STANDARD TABLE OF REF TO zif_demand_reader WITH EMPTY KEY.

    "! <p class="shorttext synchronized">Read the demand of several sources as one list</p>
    "!
    "! Stock is one pool, so everything competing for it has to reach the
    "! strategy in one list. Add a source per kind of requirement rather than
    "! growing one reader that knows about all of them.
    "!
    "! @parameter it_source | <p class="shorttext synchronized">Where demand comes from, one per kind</p>
    METHODS constructor
      IMPORTING
        it_source TYPE ty_source_tab.

  PRIVATE SECTION.
    DATA mt_source TYPE ty_source_tab.

ENDCLASS.


CLASS zcl_demand_sources IMPLEMENTATION.

  METHOD constructor.
    mt_source = it_source.
  ENDMETHOD.

  METHOD zif_demand_reader~read_open_demand.

    " a source that cannot answer stops the read rather than being left out:
    " allocating on demand that is known to be incomplete would give stock away
    " to whoever happens to be readable
    LOOP AT mt_source INTO DATA(lo_source).
      APPEND LINES OF lo_source->read_open_demand(
        iv_matnr = iv_matnr
        iv_werks = iv_werks ) TO rt_demand.
    ENDLOOP.

  ENDMETHOD.

  METHOD zif_demand_reader~materials_with_demand.

    LOOP AT mt_source INTO DATA(lo_source).
      APPEND LINES OF lo_source->materials_with_demand( iv_werks ) TO rt_matnr.
    ENDLOOP.

    " a material wanted by an order and by a transfer is still allocated once
    SORT rt_matnr ASCENDING.
    DELETE ADJACENT DUPLICATES FROM rt_matnr.

  ENDMETHOD.

ENDCLASS.

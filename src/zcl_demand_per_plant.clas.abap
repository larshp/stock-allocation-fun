CLASS zcl_demand_per_plant DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_demand_reader.

    "! <p class="shorttext synchronized">Wire up the reader</p>
    "!
    "! @parameter io_config | <p class="shorttext synchronized">Where a plant's settings come from</p>
    METHODS constructor
      IMPORTING
        io_config TYPE REF TO zif_alloc_config OPTIONAL.

  PRIVATE SECTION.

    "! One plant's reader, once it has been built.
    TYPES:
      BEGIN OF ty_reader,
        werks  TYPE mard-werks,
        reader TYPE REF TO zif_demand_reader,
      END OF ty_reader.
    TYPES ty_reader_tab TYPE STANDARD TABLE OF ty_reader WITH EMPTY KEY.

    DATA mo_config TYPE REF TO zif_alloc_config.
    DATA mt_reader TYPE ty_reader_tab.

    METHODS reader_for
      IMPORTING
        iv_werks         TYPE mard-werks
      RETURNING
        VALUE(ro_reader) TYPE REF TO zif_demand_reader.

ENDCLASS.


CLASS zcl_demand_per_plant IMPLEMENTATION.

  METHOD constructor.

    mo_config = io_config.
    IF mo_config IS NOT BOUND.
      mo_config = NEW zcl_alloc_config( ).
    ENDIF.

  ENDMETHOD.

  METHOD zif_demand_reader~read_open_demand.

    rt_demand = reader_for( iv_werks )->read_open_demand(
      iv_matnr = iv_matnr
      iv_werks = iv_werks ).

  ENDMETHOD.

  METHOD zif_demand_reader~materials_with_demand.

    rt_matnr = reader_for( iv_werks )->materials_with_demand( iv_werks ).

  ENDMETHOD.

  METHOD reader_for.

    " the other half of ZCL_SUPPLY_PER_PLANT, and for the same reason: a plant
    " looks as far ahead as it has said it does, ships in as many days as it
    " takes, and ranks transfers where it has put them. Its demand read through
    " another plant's settings is a different set of lines.
    IF line_exists( mt_reader[ werks = iv_werks ] ).
      ro_reader = mt_reader[ werks = iv_werks ]-reader.
      RETURN.
    ENDIF.

    ro_reader = zcl_allocation_service=>create_default_open_demand(
      is_settings = mo_config->for_plant( iv_werks ) ).

    APPEND VALUE #(
      werks  = iv_werks
      reader = ro_reader ) TO mt_reader.

  ENDMETHOD.

ENDCLASS.

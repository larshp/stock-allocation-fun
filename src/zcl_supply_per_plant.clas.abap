CLASS zcl_supply_per_plant DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_supply_reader.

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
        reader TYPE REF TO zif_supply_reader,
      END OF ty_reader.
    TYPES ty_reader_tab TYPE STANDARD TABLE OF ty_reader WITH EMPTY KEY.

    DATA mo_config  TYPE REF TO zif_alloc_config.
    DATA mt_reader  TYPE ty_reader_tab.

    METHODS reader_for
      IMPORTING
        iv_werks         TYPE mard-werks
      RETURNING
        VALUE(ro_reader) TYPE REF TO zif_supply_reader.

ENDCLASS.


CLASS zcl_supply_per_plant IMPLEMENTATION.

  METHOD constructor.

    mo_config = io_config.
    IF mo_config IS NOT BOUND.
      mo_config = NEW zcl_alloc_config( ).
    ENDIF.

  ENDMETHOD.

  METHOD zif_supply_reader~read_supply.

    rt_supply = reader_for( iv_werks )->read_supply(
      iv_matnr = iv_matnr
      iv_werks = iv_werks ).

  ENDMETHOD.

  METHOD reader_for.

    " a plant reads its own supply its own way: its storage locations, and
    " whether it counts its own plan. A caller that asks about several plants
    " with one plant's reader is told what that plant would have had, which is
    " a different number and looks like the same one.
    IF line_exists( mt_reader[ werks = iv_werks ] ).
      ro_reader = mt_reader[ werks = iv_werks ]-reader.
      RETURN.
    ENDIF.

    " one reader per plant for the life of this one, because the settings
    " cannot change during a run and building it reads Customizing
    ro_reader = zcl_allocation_service=>create_default_supply(
      is_settings = mo_config->for_plant( iv_werks ) ).

    APPEND VALUE #(
      werks  = iv_werks
      reader = ro_reader ) TO mt_reader.

  ENDMETHOD.

ENDCLASS.

CLASS zcl_supply_sources DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_supply_reader.

    TYPES ty_source_tab TYPE STANDARD TABLE OF REF TO zif_supply_reader WITH EMPTY KEY.

    "! <p class="shorttext synchronized">Read the supply of several sources as one list</p>
    "!
    "! Everything that can be given away has to reach the engine as one
    "! timeline. Add a source per kind of supply rather than growing one reader
    "! that knows about all of them.
    "!
    "! @parameter it_source | <p class="shorttext synchronized">Where supply comes from, one per kind</p>
    METHODS constructor
      IMPORTING
        it_source TYPE ty_source_tab OPTIONAL.

  PRIVATE SECTION.
    DATA mt_source TYPE ty_source_tab.

ENDCLASS.


CLASS zcl_supply_sources IMPLEMENTATION.

  METHOD constructor.
    mt_source = it_source.
  ENDMETHOD.

  METHOD zif_supply_reader~read_supply.

    " a source that cannot answer stops the read rather than being left out.
    " Allocating on supply that is known to be incomplete would hold stock back
    " from demand that could have had it.
    LOOP AT mt_source INTO DATA(lo_source).
      APPEND LINES OF lo_source->read_supply(
        iv_matnr = iv_matnr
        iv_werks = iv_werks ) TO rt_supply.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.

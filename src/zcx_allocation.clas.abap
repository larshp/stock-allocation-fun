CLASS zcx_allocation DEFINITION
  PUBLIC
  INHERITING FROM cx_static_check
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_t100_message.

    CONSTANTS:
      BEGIN OF save_failed,
        msgid TYPE symsgid VALUE 'ZSTOCK_ALLOC',
        msgno TYPE symsgno VALUE '001',
        attr1 TYPE scx_attrname VALUE 'MV_RUN_ID',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF save_failed.

    DATA mv_run_id TYPE string READ-ONLY.

    "! <p class="shorttext synchronized">Raise a stock allocation error</p>
    "!
    "! @parameter textid    | <p class="shorttext synchronized">Message, one of the constants above</p>
    "! @parameter previous  | <p class="shorttext synchronized">Exception that caused this one</p>
    "! @parameter mv_run_id | <p class="shorttext synchronized">Allocation run, fills placeholder &amp;1</p>
    METHODS constructor
      IMPORTING
        textid    LIKE if_t100_message=>t100key OPTIONAL
        previous  LIKE previous OPTIONAL
        mv_run_id TYPE string OPTIONAL.

ENDCLASS.


CLASS zcx_allocation IMPLEMENTATION.

  METHOD constructor.

    super->constructor( previous = previous ).

    me->mv_run_id = mv_run_id.

    CLEAR me->textid.
    IF textid IS INITIAL.
      if_t100_message~t100key = if_t100_message=>default_textid.
    ELSE.
      if_t100_message~t100key = textid.
    ENDIF.

  ENDMETHOD.

ENDCLASS.

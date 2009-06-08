// $ANTLR 3.1.2 C:\\Users\\jartur\\p\\spc\\spc\\spc.g 2009-06-08 20:41:23

// The variable 'variable' is assigned but its value is never used.
#pragma warning disable 168, 219
// Unreachable code detected.
#pragma warning disable 162
namespace  spc 
{

using System;
using Antlr.Runtime;
using IList 		= System.Collections.IList;
using ArrayList 	= System.Collections.ArrayList;
using Stack 		= Antlr.Runtime.Collections.StackList;


public partial class spcParser : Parser
{
    public static readonly string[] tokenNames = new string[] 
	{
        "<invalid>", 
		"<EOR>", 
		"<DOWN>", 
		"<UP>", 
		"ID"
    };

    public const int ID = 4;
    public const int EOF = -1;

    // delegates
    // delegators



        public spcParser(ITokenStream input)
    		: this(input, new RecognizerSharedState()) {
        }

        public spcParser(ITokenStream input, RecognizerSharedState state)
    		: base(input, state) {
            InitializeCyclicDFAs();

             
        }
        

    override public string[] TokenNames {
		get { return spcParser.tokenNames; }
    }

    override public string GrammarFileName {
		get { return "C:\\Users\\jartur\\p\\spc\\spc\\spc.g"; }
    }



    // $ANTLR start "prog"
    // C:\\Users\\jartur\\p\\spc\\spc\\spc.g:10:1: prog : ( ID )+ ;
    public void prog() // throws RecognitionException [1]
    {   
        try 
    	{
            // C:\\Users\\jartur\\p\\spc\\spc\\spc.g:10:6: ( ( ID )+ )
            // C:\\Users\\jartur\\p\\spc\\spc\\spc.g:10:8: ( ID )+
            {
            	// C:\\Users\\jartur\\p\\spc\\spc\\spc.g:10:8: ( ID )+
            	int cnt1 = 0;
            	do 
            	{
            	    int alt1 = 2;
            	    int LA1_0 = input.LA(1);

            	    if ( (LA1_0 == ID) )
            	    {
            	        alt1 = 1;
            	    }


            	    switch (alt1) 
            		{
            			case 1 :
            			    // C:\\Users\\jartur\\p\\spc\\spc\\spc.g:10:8: ID
            			    {
            			    	Match(input,ID,FOLLOW_ID_in_prog27); 

            			    }
            			    break;

            			default:
            			    if ( cnt1 >= 1 ) goto loop1;
            		            EarlyExitException eee1 =
            		                new EarlyExitException(1, input);
            		            throw eee1;
            	    }
            	    cnt1++;
            	} while (true);

            	loop1:
            		;	// Stops C# compiler whinging that label 'loop1' has no statements


            }

        }
        catch (RecognitionException re) 
    	{
            ReportError(re);
            Recover(input,re);
        }
        finally 
    	{
        }
        return ;
    }
    // $ANTLR end "prog"

    // Delegated rules


	private void InitializeCyclicDFAs()
	{
	}

 

    public static readonly BitSet FOLLOW_ID_in_prog27 = new BitSet(new ulong[]{0x0000000000000012UL});

}
}
// $ANTLR 3.1.2 C:\\Users\\jartur\\p\\spc\\spc\\spc.g 2009-06-08 20:41:23

// The variable 'variable' is assigned but its value is never used.
#pragma warning disable 168, 219
// Unreachable code detected.
#pragma warning disable 162

using System;
using Antlr.Runtime;
using IList 		= System.Collections.IList;
using ArrayList 	= System.Collections.ArrayList;
using Stack 		= Antlr.Runtime.Collections.StackList;


public partial class spcLexer : Lexer {
    public const int ID = 4;
    public const int EOF = -1;

    // delegates
    // delegators

    public spcLexer() 
    {
		InitializeCyclicDFAs();
    }
    public spcLexer(ICharStream input)
		: this(input, null) {
    }
    public spcLexer(ICharStream input, RecognizerSharedState state)
		: base(input, state) {
		InitializeCyclicDFAs(); 

    }
    
    override public string GrammarFileName
    {
    	get { return "C:\\Users\\jartur\\p\\spc\\spc\\spc.g";} 
    }

    // $ANTLR start "ID"
    public void mID() // throws RecognitionException [2]
    {
    		try
    		{
            int _type = ID;
    	int _channel = DEFAULT_TOKEN_CHANNEL;
            // C:\\Users\\jartur\\p\\spc\\spc\\spc.g:11:4: ( ( 'a' .. 'z' )+ )
            // C:\\Users\\jartur\\p\\spc\\spc\\spc.g:11:6: ( 'a' .. 'z' )+
            {
            	// C:\\Users\\jartur\\p\\spc\\spc\\spc.g:11:6: ( 'a' .. 'z' )+
            	int cnt1 = 0;
            	do 
            	{
            	    int alt1 = 2;
            	    int LA1_0 = input.LA(1);

            	    if ( ((LA1_0 >= 'a' && LA1_0 <= 'z')) )
            	    {
            	        alt1 = 1;
            	    }


            	    switch (alt1) 
            		{
            			case 1 :
            			    // C:\\Users\\jartur\\p\\spc\\spc\\spc.g:11:7: 'a' .. 'z'
            			    {
            			    	MatchRange('a','z'); 

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

            state.type = _type;
            state.channel = _channel;
        }
        finally 
    	{
        }
    }
    // $ANTLR end "ID"

    override public void mTokens() // throws RecognitionException 
    {
        // C:\\Users\\jartur\\p\\spc\\spc\\spc.g:1:8: ( ID )
        // C:\\Users\\jartur\\p\\spc\\spc\\spc.g:1:10: ID
        {
        	mID(); 

        }


    }


	private void InitializeCyclicDFAs()
	{
	}

 
    
}

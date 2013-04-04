/**
 *
 * Hungry Hero Game
 * http://www.hungryherogame.com
 * 
 * Copyright (c) 2012 Hemanth Sharma (www.hsharma.com). All rights reserved.
 * 
 * This ActionScript source code is free.
 * You can redistribute and/or modify it in accordance with the
 * terms of the accompanying Simplified BSD License Agreement.
 *  
 */

package sound
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.media.Sound;

	/**
	 * This class holds all the sound embeds and objects that are used in the game. 
	 * 
	 * @author hsharma
	 * 
	 */
	public class Sounds extends EventDispatcher
	{
		// Embedded sound files. 	
		[Embed(source="../../bin-debug/files/assets/hungryHero/sounds/bgWelcome.mp3")]
		public static const SND_BG_MAIN:Class;
	
		[Embed(source="../../bin-debug/files/assets/hungryHero/sounds/coffee.mp3")]
		public static const SND_COFFEE:Class;
		
		[Embed(source="../../bin-debug/files/assets/hungryHero/sounds/mushroom.mp3")]
		public static const SND_MUSHROOM:Class;

		// Initialized Sound objects. 	
		public static var sndBgMain:Sound = new Sounds.SND_BG_MAIN() as Sound;
		public static var sndCoffee:Sound = new Sounds.SND_COFFEE() as Sound;
		public static var sndMushroom:Sound = new Sounds.SND_MUSHROOM() as Sound;
	
		// Sound mute status.
		private static var _muted:Boolean = false;
		
		private static var _instance:Sounds;
		
		public static function get instance():Sounds
		{
			if ( !_instance ) {
				_instance = new Sounds();
			}
			
			return _instance;
		}
		
		public static function get muted():Boolean
		{
			return _muted;
		}
		public static function set muted( value:Boolean ):void
		{
			if ( _muted != value ) {
				_muted = value;
				instance.dispatchEvent( new Event(Event.CHANGE) );
			}
		}
	}
}
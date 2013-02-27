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
	import flash.media.Sound;

	/**
	 * This class holds all the sound embeds and objects that are used in the game. 
	 * 
	 * @author hsharma
	 * 
	 */
	public class Sounds
	{
		/**
		 * Embedded sound files. 
		 */		
		[Embed(source="../../bin-debug/files/assets/hungryHero/sounds/bgGame.mp3")]
		public static const SND_BG_GAME:Class;
		
		[Embed(source="../../bin-debug/files/assets/hungryHero/sounds/bgWelcome.mp3")]
		public static const SND_BG_MAIN:Class;
		
		[Embed(source="../../bin-debug/files/assets/hungryHero/sounds/eat.mp3")]
		public static const SND_EAT:Class;
		
		[Embed(source="../../bin-debug/files/assets/hungryHero/sounds/coffee.mp3")]
		public static const SND_COFFEE:Class;
		
		[Embed(source="../../bin-debug/files/assets/hungryHero/sounds/mushroom.mp3")]
		public static const SND_MUSHROOM:Class;
		
		[Embed(source="../../bin-debug/files/assets/hungryHero/sounds/hit.mp3")]
		public static const SND_HIT:Class;
		
		[Embed(source="../../bin-debug/files/assets/hungryHero/sounds/hurt.mp3")]
		public static const SND_HURT:Class;
		
		[Embed(source="../../bin-debug/files/assets/hungryHero/sounds/lose.mp3")]
		public static const SND_LOSE:Class;
		
		/**
		 * Initialized Sound objects. 
		 */		
		public static var sndBgMain:Sound = new Sounds.SND_BG_MAIN() as Sound;
		public static var sndBgGame:Sound = new Sounds.SND_BG_GAME() as Sound;
		public static var sndEat:Sound = new Sounds.SND_EAT() as Sound;
		public static var sndCoffee:Sound = new Sounds.SND_COFFEE() as Sound;
		public static var sndMushroom:Sound = new Sounds.SND_MUSHROOM() as Sound;
		public static var sndHit:Sound = new Sounds.SND_HIT() as Sound;
		public static var sndHurt:Sound = new Sounds.SND_HURT() as Sound;
		public static var sndLose:Sound = new Sounds.SND_LOSE() as Sound;
		
		/**
		 * Sound mute status. 
		 */
		public static var muted:Boolean = false;
	}
}
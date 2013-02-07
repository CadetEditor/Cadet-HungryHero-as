package
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.ByteArray;
	
	import cadet.core.CadetScene;
	import cadet.events.RendererEvent;
	
	import cadet2D.components.behaviours.MouseFollowBehaviour;
	import cadet2D.components.behaviours.ParallaxBehaviour;
	import cadet2D.components.core.Entity;
	import cadet2D.components.renderers.Renderer2D;
	import cadet2D.components.skins.AbstractSkin2D;
	import cadet2D.components.skins.ImageSkin;
	import cadet2D.components.skins.MovieClipSkin;
	import cadet2D.components.textures.TextureAtlasComponent;
	import cadet2D.components.textures.TextureComponent;
	import cadet2D.components.transforms.Transform2D;
	import cadet2D.events.SkinEvent;
	
	[SWF( width="1024", height="768", backgroundColor="0x002135", frameRate="60" )]
	public class Cadet_HungryHero_Code extends Sprite
	{
		private var cadetScene:CadetScene;
		
		[Embed(source="../bin-debug/files/assets/hungryHero/graphics/bgLayer1.jpg")]
		private var SkyAsset:Class;
		[Embed(source="../bin-debug/files/assets/hungryHero/graphics/mySpriteSheet.png")]
		private var SpriteSheetAsset:Class;
		[Embed(source="../bin-debug/files/assets/hungryHero/graphics/mySpriteSheet.xml", mimeType="application/octet-stream")]
		private var SpriteSheetXML:Class;
		
		private var allSprites:TextureComponent;
		private var allSpritesAtlas:TextureAtlasComponent;
		
		private var parallaxSpeed:int = -15;
		
		private var skySkin			:ImageSkin;
		private var hillsSkin		:ImageSkin;
		private var midgroundSkin	:ImageSkin;
		private var foregroundSkin	:ImageSkin;
		
		public function Cadet_HungryHero_Code()
		{
			cadetScene = new CadetScene();
			
			var renderer:Renderer2D = new Renderer2D(true);
			renderer.viewportWidth = stage.stageWidth;
			renderer.viewportHeight = stage.stageHeight;
			renderer.addEventListener(RendererEvent.INITIALISED, init);
			cadetScene.children.addItem(renderer);
			renderer.enable(this);
		}
		
		private function init( event:RendererEvent ):void
		{
			// Add the main texture to the scene
			allSprites = new TextureComponent();
			allSprites.bitmapData = new SpriteSheetAsset().bitmapData;
			cadetScene.children.addItem(allSprites);
			
			var xmlFile:ByteArray = new SpriteSheetXML();
			var xmlStr:String = xmlFile.readUTFBytes( xmlFile.length );
			
			// Add the main texture atlas to the scene
			allSpritesAtlas = new TextureAtlasComponent()
			allSpritesAtlas.texture = allSprites;
			allSpritesAtlas.xml = new XML( xmlStr );
			cadetScene.children.addItem(allSpritesAtlas);
			
			// Add the sky texture to the scene
			var skyTexture:TextureComponent = new TextureComponent();
			skyTexture.bitmapData = new SkyAsset().bitmapData;
			cadetScene.children.addItem(skyTexture);
			
			// Add the sky to the scene
			var sky:Entity = new Entity();
			cadetScene.children.addItem(sky);
			// Add an ImageSkin to the sky Entity
			skySkin = new ImageSkin();
			skySkin.texture = skyTexture;
			skySkin.addEventListener(SkinEvent.TEXTURE_VALIDATED, textureValidatedHandler);
			sky.children.addItem(skySkin);

			// Add the background hills to the scene
			var hills:Entity = new Entity();
			cadetScene.children.addItem(hills);
			// Add an ImageSkin to the hills Entity
			hillsSkin = new ImageSkin();
			hillsSkin.textureAtlas = allSpritesAtlas;
			hillsSkin.texturesPrefix = "bgLayer2";
			hillsSkin.y = 290;
			hillsSkin.addEventListener(SkinEvent.TEXTURE_VALIDATED, textureValidatedHandler);
			hills.children.addItem(hillsSkin);
			
			// Add the midground to the scene
			var midground:Entity = new Entity();
			cadetScene.children.addItem(midground);
			// Add an ImageSkin to the midground Entity
			midgroundSkin = new ImageSkin();
			midgroundSkin.textureAtlas = allSpritesAtlas;
			midgroundSkin.texturesPrefix = "bgLayer3";	
			midgroundSkin.y = 360;
			midgroundSkin.addEventListener(SkinEvent.TEXTURE_VALIDATED, textureValidatedHandler);
			midground.children.addItem(midgroundSkin);			
			
			// Add the foreground to the scene
			var foreground:Entity = new Entity();
			cadetScene.children.addItem(foreground);
			// Add an ImageSkin to the foreground Entity
			foregroundSkin = new ImageSkin();
			foregroundSkin.textureAtlas = allSpritesAtlas;
			foregroundSkin.texturesPrefix = "bgLayer4";	
			foregroundSkin.y = 450;
			foregroundSkin.addEventListener(SkinEvent.TEXTURE_VALIDATED, textureValidatedHandler);
			foreground.children.addItem(foregroundSkin);	
			
			// Add Hero entity to the scene
			var hero:Entity = new Entity();
			cadetScene.children.addItem(hero);
			// Add a 2D transform
			var transform2D:Transform2D = new Transform2D();
			transform2D.x = 50;
			hero.children.addItem(transform2D);
			// Add an animatable MovieClipSkin
			var mcSkin:MovieClipSkin = new MovieClipSkin();
			mcSkin.textureAtlas = allSpritesAtlas;
			mcSkin.texturesPrefix = "fly_";
			mcSkin.loop = true;
			hero.children.addItem(mcSkin);
			// Add the MouseFollowBehaviour
			var mouseFollow:MouseFollowBehaviour = new MouseFollowBehaviour();
			mouseFollow.constrain = MouseFollowBehaviour.CONSTRAIN_X;
			hero.children.addItem(mouseFollow);

			
			addEventListener( Event.ENTER_FRAME, enterFrameHandler );			
		}
		
		private function textureValidatedHandler( event:SkinEvent ):void
		{
			var parallax:ParallaxBehaviour;
			var skin:AbstractSkin2D = AbstractSkin2D(event.target);
			
			if ( skin == skySkin ) {
				// Add a ParallaxBehaviour to the sky Entity
				parallax = new ParallaxBehaviour();
				parallax.depth = 0.1;
				parallax.speed = parallaxSpeed;
				skySkin.parentComponent.children.addItem(parallax);
				skySkin.removeEventListener(SkinEvent.TEXTURE_VALIDATED, textureValidatedHandler);
			} else if ( skin == hillsSkin ) {
				// Add a ParallaxBehaviour to the hills Entity
				parallax = new ParallaxBehaviour();
				parallax.depth = 0.3;
				parallax.speed = parallaxSpeed;
				hillsSkin.parentComponent.children.addItem(parallax);
				hillsSkin.removeEventListener(SkinEvent.TEXTURE_VALIDATED, textureValidatedHandler);	
			} else if ( skin == midgroundSkin ) {
				// Add a ParallaxBehaviour to the midground Entity
				parallax = new ParallaxBehaviour();
				parallax.depth = 0.6;
				parallax.speed = parallaxSpeed;
				midgroundSkin.parentComponent.children.addItem(parallax);
				midgroundSkin.removeEventListener(SkinEvent.TEXTURE_VALIDATED, textureValidatedHandler);
			} else if ( skin == foregroundSkin ) {
				// Add a ParallaxBehaviour to the midground Entity
				parallax = new ParallaxBehaviour();
				parallax.depth = 1;
				parallax.speed = parallaxSpeed;
				foregroundSkin.parentComponent.children.addItem(parallax);
				foregroundSkin.removeEventListener(SkinEvent.TEXTURE_VALIDATED, textureValidatedHandler);				
			}
		}
		
		private function enterFrameHandler( event:Event ):void
		{
			cadetScene.step();
		}
	}
}
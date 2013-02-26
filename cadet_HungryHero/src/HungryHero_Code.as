package
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.ByteArray;
	
	import cadet.core.CadetScene;
	import cadet.events.RendererEvent;
	
	import cadet2D.components.behaviours.MouseFollowBehaviour;
	import cadet2D.components.core.Entity;
	import cadet2D.components.renderers.Renderer2D;
	import cadet2D.components.skins.AbstractSkin2D;
	import cadet2D.components.skins.ImageSkin;
	import cadet2D.components.skins.MovieClipSkin;
	import cadet2D.components.textures.TextureAtlasComponent;
	import cadet2D.components.textures.TextureComponent;
	import cadet2D.components.transforms.Transform2D;
	import cadet2D.events.SkinEvent;
	
	import hungryHero.components.behaviours.MagnetBehaviour;
	import hungryHero.components.behaviours.MoveBehaviour;
	import hungryHero.components.behaviours.ObstacleBehaviour;
	import hungryHero.components.behaviours.ParallaxBehaviour;
	import hungryHero.components.behaviours.SpeedUpBehaviour;
	import hungryHero.components.processes.BackgroundsProcess;
	import hungryHero.components.processes.GlobalsProcess;
	import hungryHero.components.processes.ItemsProcess;
	import hungryHero.components.processes.ObstaclesProcess;
	
	[SWF( width="1024", height="768", backgroundColor="0x002135", frameRate="60" )]
	public class HungryHero_Code extends Sprite
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
		
		private var heroSkin		:MovieClipSkin;
		
		public function HungryHero_Code()
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
			
			// Add the Global variables
			var globals:GlobalsProcess = new GlobalsProcess();
			cadetScene.children.addItem(globals);
			
			addBackgrounds();			
			addHero();
			addItems();
			addObstacles();
			
			addEventListener( Event.ENTER_FRAME, enterFrameHandler );			
		}
		
		private function addBackgrounds():void
		{
			// Add the sky texture to the scene
			var skyTexture:TextureComponent = new TextureComponent();
			skyTexture.bitmapData = new SkyAsset().bitmapData;
			cadetScene.children.addItem(skyTexture);
			
			var backgroundsProcess:BackgroundsProcess = new BackgroundsProcess();
			cadetScene.children.addItem(backgroundsProcess);
			
			// Add the sky to the scene
			var sky:Entity = new Entity();
			cadetScene.children.addItem(sky);
			// Add an ImageSkin to the sky Entity
			skySkin = new ImageSkin();
			sky.children.addItem(skySkin);
			skySkin.texture = skyTexture;
			skySkin.addEventListener(SkinEvent.TEXTURE_VALIDATED, textureValidatedHandler);
			
			// Add the background hills to the scene
			var hills:Entity = new Entity();
			cadetScene.children.addItem(hills);
			// Add an ImageSkin to the hills Entity
			hillsSkin = new ImageSkin();
			hills.children.addItem(hillsSkin);
			hillsSkin.textureAtlas = allSpritesAtlas;
			hillsSkin.texturesPrefix = "bgLayer2";
			hillsSkin.y = 290;
			hillsSkin.addEventListener(SkinEvent.TEXTURE_VALIDATED, textureValidatedHandler);
			
			// Add the midground to the scene
			var midground:Entity = new Entity();
			cadetScene.children.addItem(midground);
			// Add an ImageSkin to the midground Entity
			midgroundSkin = new ImageSkin();
			midground.children.addItem(midgroundSkin);	
			midgroundSkin.textureAtlas = allSpritesAtlas;
			midgroundSkin.texturesPrefix = "bgLayer3";	
			midgroundSkin.y = 360;
			midgroundSkin.addEventListener(SkinEvent.TEXTURE_VALIDATED, textureValidatedHandler);
			
			// Add the foreground to the scene
			var foreground:Entity = new Entity();
			cadetScene.children.addItem(foreground);
			// Add an ImageSkin to the foreground Entity
			foregroundSkin = new ImageSkin();
			foreground.children.addItem(foregroundSkin);
			foregroundSkin.textureAtlas = allSpritesAtlas;
			foregroundSkin.texturesPrefix = "bgLayer4";	
			foregroundSkin.y = 450;
			foregroundSkin.addEventListener(SkinEvent.TEXTURE_VALIDATED, textureValidatedHandler);
				
		}
		
		private function addHero():void
		{
			// Add Hero entity to the scene
			var hero:Entity = new Entity();
			cadetScene.children.addItem(hero);
			// Add a 2D transform
			var transform2D:Transform2D = new Transform2D();
			transform2D.x = 50;
			hero.children.addItem(transform2D);
			// Add an animatable MovieClipSkin
			heroSkin = new MovieClipSkin();
			heroSkin.textureAtlas = allSpritesAtlas;
			heroSkin.texturesPrefix = "fly_";
			heroSkin.loop = true;
			hero.children.addItem(heroSkin);
			// Add the MouseFollowBehaviour
			var mouseFollow:MouseFollowBehaviour = new MouseFollowBehaviour();
			mouseFollow.constrain = MouseFollowBehaviour.CONSTRAIN_X;
			hero.children.addItem(mouseFollow);
		}
		
		private function addItems():void
		{
			// Add the Items Entity
			var itemsEntity:Entity = new Entity();
			cadetScene.children.addItem(itemsEntity);
			
			for ( var i:uint = 0; i < 5; i ++ ) {
				// Add an ImageSkin to the itemsEntity
				var imageSkin:ImageSkin = new ImageSkin();
				imageSkin.textureAtlas = allSpritesAtlas;
				imageSkin.texturesPrefix = "item"+(i+1);
				itemsEntity.children.addItem(imageSkin);				
			}
			
			// Add the Powerups Entity
			var powerupsEntity:Entity = new Entity();
			cadetScene.children.addItem(powerupsEntity);
			
			// Add Coffee powerup
			var powerup:Entity = new Entity();
			powerupsEntity.children.addItem(powerup);
			imageSkin = new ImageSkin();
			powerup.children.addItem(imageSkin);
			imageSkin.textureAtlas = allSpritesAtlas;
			imageSkin.texturesPrefix = "item6";
			var speedUpBehaviour:SpeedUpBehaviour = new SpeedUpBehaviour();
			powerup.children.addItem(speedUpBehaviour);
			
			// Add Mushroom powerup
			powerup = new Entity();
			powerupsEntity.children.addItem(powerup);
			imageSkin = new ImageSkin();
			powerup.children.addItem(imageSkin);
			imageSkin.textureAtlas = allSpritesAtlas;
			imageSkin.texturesPrefix = "item7";
			var magnetBehaviour:MagnetBehaviour = new MagnetBehaviour();
			powerup.children.addItem(magnetBehaviour);
			magnetBehaviour.targetTransform = heroSkin;
			
			var itemsProcess:ItemsProcess = new ItemsProcess();
			cadetScene.children.addItem(itemsProcess);
			itemsProcess.itemsContainer = itemsEntity;
			itemsProcess.powerupsContainer = powerupsEntity;
			itemsProcess.hitTestSkin = heroSkin;
			//itemsProcess.moveBehaviour = moveBehaviour;
			
			var moveBehaviour:MoveBehaviour = new MoveBehaviour();
			itemsProcess.children.addItem(moveBehaviour);
			moveBehaviour.angle = 270;
		}
		
		private function addObstacles():void
		{
			// Add the Obstacles Entity
			var obstaclesEntity:Entity = new Entity();
			cadetScene.children.addItem(obstaclesEntity);
			
			for ( var i:uint = 0; i < 3; i ++ ) {
				var obstacle:Entity = new Entity();
				// Add the default ImageSkin to the obstacle entity
				var defaultSkin:ImageSkin = new ImageSkin();
				obstacle.children.addItem(defaultSkin);
				defaultSkin.textureAtlas = allSpritesAtlas;
				defaultSkin.texturesPrefix = "obstacle"+(i+1);
				// Add the crash ImageSkin to the obstacle entity
				var crashSkin:ImageSkin = new ImageSkin();
				obstacle.children.addItem(crashSkin);
				crashSkin.textureAtlas = allSpritesAtlas;
				crashSkin.texturesPrefix = "obstacle"+(i+1)+"_crash";
				// Add the Transform2D to the obstacle entity
				var transform:Transform2D = new Transform2D();
				obstacle.children.addItem(transform);
				// Add the ObstacleBehaviour to the obstacle entity
				var behaviour:ObstacleBehaviour = new ObstacleBehaviour();
				obstacle.children.addItem(behaviour);
				behaviour.defaultSkin = defaultSkin;
				behaviour.crashSkin = crashSkin;
				// Finally, add the obstacle entity to the container entity
				obstaclesEntity.children.addItem(obstacle);				
			}
			
			var obstaclesProcess:ObstaclesProcess = new ObstaclesProcess();
			cadetScene.children.addItem(obstaclesProcess);
			obstaclesProcess.obstaclesContainer = obstaclesEntity;
			obstaclesProcess.hitTestSkin = heroSkin;
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